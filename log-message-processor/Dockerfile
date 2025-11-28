FROM python:3.8-alpine

WORKDIR /app

# Copy requirements.txt and install dependencies
COPY requirements.txt ./
RUN apk add --no-cache build-base python3-dev
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the source code
COPY . .

# Command to run the application
CMD ["python", "main.py"]
