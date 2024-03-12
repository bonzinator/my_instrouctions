#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import json
import pika
import time
import itertools
import requests
from requests.auth import HTTPBasicAuth


HOST = 'rabbit'
USERNAME = 'guest'
PASSWORD = 'guest'


management = f'http://{HOST}:15672'
params = pika.ConnectionParameters(
                    host=HOST,
                    port=5672,
                    virtual_host='/',
                    credentials=pika.PlainCredentials(
                        username=USERNAME,
                        password=PASSWORD
                    )
                )


management = f'http://{HOST}:15672'

def create_shovel(q_from, x_to) -> str:
    shovel_name = f'{q_from}__to__{x_to}'

    content = {
      "value": {
        "src-protocol": "amqp091",
        "src-uri": "amqp://",
        "src-queue": q_from,
        "dest-protocol": "amqp091",
        "dest-uri": "amqp://",
        "dest-queue": x_to
      }
    }
    resp = requests.put(
        f'{management}/api/parameters/shovel/%2F/{shovel_name}',
        json.dumps(content),
        auth=HTTPBasicAuth(USERNAME, PASSWORD)
    )

    return shovel_name


connection = None
channel = None
def try_connect():
    global connection
    global channel
    try:
        connection = pika.BlockingConnection(params)
        channel = connection.channel()
        return True
    except Exception:
        return False


for i in range(300):
    if try_connect():
        break
    time.sleep(2)

if channel is None:
    assert False, 'could not connect to ' + HOST

queue_list = ['q_cat', 'q_dog', 'q_poll', 'q_hamster', 'q_squirrel']

queue_dict = {
  'q_cat': 'cat',
  'q_dog': 'dog',
  'q_poll': 'poll',
  'q_hamster': 'hamster',
  'q_squirrel': 'squirrel'
}

proxy_dict = {}


channel = connection.channel()

for i, d in queue_dict.items():
    proxy_i = f'p{i}'
    proxy_dict[i] = proxy_i
    channel.queue_declare(queue=i)
    channel.queue_declare(queue=proxy_i)

channel.exchange_declare('x_main', exchange_type='topic', durable=True)


for i, d in queue_dict.items():
    channel.queue_bind(i, 'x_main', d)


for i, d in proxy_dict.items():
    create_shovel(i, d)


connection.close()
