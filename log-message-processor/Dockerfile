FROM python:3.8-slim-bullseye

WORKDIR /app

# Install build dependencies needed for thriftpy
RUN apt-get update && apt-get install -y build-essential python3-dev

# Copy requirements.txt and install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the source code
COPY . .

# Command to run the application
CMD ["python", "main.py"]
