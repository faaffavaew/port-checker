FROM python:3.10

ENV PYTHONUNBUFFERED=1

WORKDIR /opt/ports_checker

RUN apt-get update && \
    apt-get install -y \
    curl \
    software-properties-common

RUN pip install --upgrade pip && \
    pip install fastapi uvicorn

COPY main.py /opt/ports_checker/main.py

EXPOSE 54172

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "54172"]
