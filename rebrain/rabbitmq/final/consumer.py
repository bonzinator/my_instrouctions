#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import pika

credentials = pika.PlainCredentials('guest', 'guest')
parameters = pika.ConnectionParameters('localhost', 5672, '/', credentials)
connection = pika.BlockingConnection(parameters)

channel = connection.channel()

def callback(ch, method, properties, body):
    print("Received %r" % body)


channel.basic_consume(queue='pq_cat', auto_ack=True, on_message_callback=callback)
channel.basic_consume(queue='pq_dog', auto_ack=True, on_message_callback=callback)
channel.basic_consume(queue='pq_poll', auto_ack=True, on_message_callback=callback)
channel.basic_consume(queue='pq_hamster', auto_ack=True, on_message_callback=callback)
channel.basic_consume(queue='pq_squirrel', auto_ack=True, on_message_callback=callback)

channel.start_consuming()

print('To exit press CTRL+C')
connection.close()

