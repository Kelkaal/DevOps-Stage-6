FROM python:3.8-slim-bullseye

WORKDIR /app

# Install build dependencies and a specific version of Cython to build thriftpy
RUN apt-get update && apt-get install -y build-essential
RUN pip install --upgrade pip
RUN pip install "cython<0.29"

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "main.py"]
