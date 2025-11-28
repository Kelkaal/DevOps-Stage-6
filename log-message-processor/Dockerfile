FROM python:3.9-alpine

WORKDIR /app

# Copy requirements.txt and install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the source code
COPY . .

# Command to run the application
CMD ["python", "main.py"]
