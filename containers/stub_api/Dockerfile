FROM python:latest
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ./*.py .
EXPOSE 80
CMD ["python", "main.py"]
