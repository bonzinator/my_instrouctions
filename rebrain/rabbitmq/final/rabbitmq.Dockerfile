FROM rabbitmq:3.10-management

ADD rabbitmq.conf /etc/rabbitmq

# SHOVEL
RUN rabbitmq-plugins enable rabbitmq_shovel
RUN rabbitmq-plugins enable rabbitmq_shovel_management