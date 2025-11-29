import time
import redis
import os
import json
import random

from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import SimpleSpanProcessor
from opentelemetry.exporter.zipkin.json import ZipkinExporter
from opentelemetry.trace import SpanContext, TraceFlags, set_span_in_context

def log_message(message):
    time_delay = random.randrange(0, 2000)
    time.sleep(time_delay / 1000)
    print('message received after waiting for {}ms: {}'.format(time_delay, message))

if __name__ == '__main__':
    redis_host = os.environ.get('REDIS_HOST', 'localhost')
    redis_port = int(os.environ.get('REDIS_PORT', 6379))
    redis_channel = os.environ.get('REDIS_CHANNEL', 'log_channel')
    zipkin_url = os.environ.get('ZIPKIN_URL')

    tracer = None
    if zipkin_url:
        print(f"Initializing Zipkin exporter to {zipkin_url}")
        provider = TracerProvider()
        exporter = ZipkinExporter(endpoint=zipkin_url)
        provider.add_span_processor(SimpleSpanProcessor(exporter))
        trace.set_tracer_provider(provider)
        tracer = trace.get_tracer("log-message-processor")

    pubsub = redis.Redis(host=redis_host, port=redis_port, db=0).pubsub()
    pubsub.subscribe([redis_channel])

    for item in pubsub.listen():
        try:
            data = item['data'].decode("utf-8")
            message = json.loads(data)
        except (UnicodeDecodeError, json.JSONDecodeError, AttributeError) as e:
            # Handle cases where the message is not valid JSON or not decodable
            log_message(f"Received non-JSON or undecodable message: {item['data']}")
            continue

        if not tracer or 'zipkinSpan' not in message:
            log_message(message)
            continue

        span_data = message.get('zipkinSpan', {})
        try:
            # Extract parent span context from the message
            trace_id = int(span_data.get('_traceId', {}).get('value', '0'), 16)
            parent_span_id = int(span_data.get('_spanId', '0'), 16)
            is_sampled = span_data.get('_sampled', {}).get('value', False)

            if not trace_id or not parent_span_id:
                log_message(message)
                continue
            
            # Create a remote SpanContext
            parent_context = SpanContext(
                trace_id=trace_id,
                span_id=parent_span_id,
                is_remote=True,
                trace_flags=TraceFlags.SAMPLED if is_sampled else TraceFlags.DEFAULT
            )

            # Create a new context from the parent span
            context = set_span_in_context(trace.NonRecordingSpan(parent_context))
            
            # Start a new span as a child of the remote parent
            with tracer.start_as_current_span("save_log", context=context):
                log_message(message)

        except Exception as e:
            print(f"Could not process trace information or send to Zipkin: {e}")
            log_message(message)
