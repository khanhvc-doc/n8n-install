FROM python:3.10-slim

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir flask gtts

EXPOSE 5000

CMD ["python", "text_to_speech.py"]
