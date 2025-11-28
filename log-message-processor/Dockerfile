FROM python:3.8

WORKDIR /app

# The full python image contains the necessary build tools.
# We first upgrade pip itself.
RUN pip install --upgrade pip

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "main.py"]
