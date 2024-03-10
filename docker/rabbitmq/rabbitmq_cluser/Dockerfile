FROM rabbitmq:3.10.7-management
# ADD definitions.json /etc/rabbitmq
ADD rabbitmq.conf /etc/rabbitmq

ADD .erlang.cookie /var/lib/rabbitmq/

ADD --chown=rabbitmq .erlang.cookie /var/lib/rabbitmq/ 
