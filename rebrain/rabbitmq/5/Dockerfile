FROM rabbitmq:3.10.7-management
ADD definitions.json /etc/rabbitmq
ADD rabbitmq.conf /etc/rabbitmq

COPY docker_certs/*.pem /etc/pki/tls/
RUN chmod 777 /etc/pki/tls/ServerKey.pem

RUN rabbitmq-plugins enable rabbitmq_auth_mechanism_ssl