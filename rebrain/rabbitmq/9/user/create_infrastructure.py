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

def create_shovel(q_from, x_to) -> str:
    shovel_name = f'{q_from}__to__{x_to}'

    content = {
        "value": {
            "src-protocol": "amqp091",      
            "src-uri":  "amqp://",
            "src-queue":  q_from,
            "dest-protocol": "amqp091",
            "dest-uri": "amqp://",
            "dest-exchange": x_to
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

# пытаeмся подключиться несколько (очень много) раз
for i in range(300):
    if try_connect():
        break
    time.sleep(2)

if channel is None:
    assert False, 'could not connect to ' + HOST

equipment_types = ['drone', 'car', 'robot', 'scooter']
countries = ['am', 'kz', 'uz', 'ge', 'de', 'fi', 'pl']
purposes = ['monitoring', 'weather', 'delivery', 'other']

# лямбда матчит ключи на попадание в очередь
final_queues = [
    ('q_drone_pl', lambda r: 'drone' in r and 'pl.' in r),
    ('q_am', lambda r: 'am.' in r),
    ('q_uz', lambda r: 'uz.' in r),
    ('q_fi', lambda r: 'fi.' in r),
    ('q_monitoring', lambda r: 'monitoring' in r),
    ('q_other', lambda r: 'other' in r),
    ('q_asia', lambda r: 'am.' in r or 'kz.' in r or 'uz.' in r or 'ge.' in r),
    ('q_scooter_europe', lambda r: 'de.' in r and 'scooter' in r),
    ('q_scooter_europe', lambda r: 'fi.' in r and 'scooter' in r),
    ('q_scooter_europe', lambda r: 'pl.' in r and 'scooter' in r),
]

# создаем первичный обменник и финальные очереди
channel.exchange_declare('x_main', exchange_type='direct', durable=True)

for final_queue, _ in final_queues:
    channel.queue_declare(final_queue, durable=True)

# создаем прокси очереди и привязки
for t, c, p in itertools.product(equipment_types, countries, purposes):
    routing_key = f'{t}.{c}.{p}'
    print(routing_key)

    proxy_q_name = f'q_{routing_key}'
    proxy_x_name = f'x_{routing_key}'

    # создаем прокси-очередь и направляем в нее сообщения
    channel.queue_declare(proxy_q_name, durable=True, arguments={'x-queue-type': 'stream'})
    channel.queue_bind(proxy_q_name, 'x_main', routing_key)

    # создаем прокси-обменник и направляем туда shovel-ом сообщения из прокси-очереди
    channel.exchange_declare(proxy_x_name, exchange_type='direct', durable=True)
    proxy_shovel_name = create_shovel(proxy_q_name, proxy_x_name)

    # привязываем финальную очередь к прокси обменнику если паттерн совпадает
    for final_queue, is_key_match in final_queues:
        if is_key_match(routing_key):
            print(f'x_main -> {proxy_q_name} -> {proxy_shovel_name} -> {proxy_x_name} -> {final_queue} ({routing_key})')
            channel.queue_bind(final_queue, proxy_x_name, routing_key)
