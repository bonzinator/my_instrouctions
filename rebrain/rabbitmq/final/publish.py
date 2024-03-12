#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import json
import pika
import time
import itertools
import requests
from requests.auth import HTTPBasicAuth


credentials = pika.PlainCredentials('guest', 'guest')
parameters = pika.ConnectionParameters('localhost', 5672, '/', credentials)
connection = pika.BlockingConnection(parameters)

channel = connection.channel()

channel.basic_publish(exchange='x_main', routing_key='cat', body='Hello cat!')
channel.basic_publish(exchange='x_main', routing_key='dog', body='Hello dog!')
channel.basic_publish(exchange='x_main', routing_key='hamster', body='Hello hamster!')
channel.basic_publish(exchange='x_main', routing_key='poll', body='Hello poll!')
channel.basic_publish(exchange='x_main', routing_key='squirrel', body='Hello squirrel!')


connection.close()

print("Your message has been sent to the queue.")

