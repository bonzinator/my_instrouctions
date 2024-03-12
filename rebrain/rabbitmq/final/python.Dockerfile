FROM python:3.10-alpine

ADD create_infra.py /

RUN pip install pika requests

ENTRYPOINT [ "python", "/create_infra.py" ]