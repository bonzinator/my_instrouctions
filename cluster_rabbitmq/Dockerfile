FROM rabbitmq:3.8.9-management

RUN apt-get update -y && apt-get install  apt-utils -y

RUN mkdir -p /etc/rabbitmq/certs

RUN openssl genrsa -out /etc/rabbitmq/certs/rabbitmq.key 2048 && \
    openssl req -new -x509 -key /etc/rabbitmq/certs/rabbitmq.key -out /etc/rabbitmq/certs/rabbitmq.crt -days 365 -subj "/CN=rabbitmq"

RUN cp /etc/rabbitmq/certs/rabbitmq.crt /usr/local/share/ca-certificate

# RUN update-ca-certificates

COPY ./advanced.config /etc/rabbitmq/

RUN chown -R rabbitmq:rabbitmq /etc/rabbitmq
