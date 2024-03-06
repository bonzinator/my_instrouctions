FROM python:3.10-alpine

ADD create_infrastructure.py /

RUN pip install pika requests

ENTRYPOINT [ "python", "create_infrastructure.py" ]