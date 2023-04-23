FROM python:3.10

WORKDIR /app

COPY requirements.txt .

RUN pip3 install --no-cache-dir -r requirements.txt

COPY app.py .

COPY templates ./templates

EXPOSE 5000

CMD ["python3", "app.py"]
