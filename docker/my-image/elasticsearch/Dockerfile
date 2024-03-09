FROM ubuntu:20.04
RUN groupadd -g 1000 elasticsearch && useradd elasticsearch -u 1000 -g 1000
RUN apt-get update && \
apt-get install -y --no-install-recommends \
apt-transport-https 
RUN mkdir /srv/elastic
COPY ./elasticsearch-7.16.3-amd64.deb /srv/elastic
RUN apt install /srv/elastic/elasticsearch-7.16.3-amd64.deb -y
COPY elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
COPY jvm.options etc/elasticsearch/jvm.options
COPY ./analysis-morphology-7.16.3.zip /srv/elastic
COPY ./ingest-attachment-7.16.3.zip /srv/elastic
#RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install file:/srv/elastic/ingest-attachment-7.16.3.zip
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install file:/srv/elastic/analysis-morphology-7.16.3.zip
COPY synonyms.txt /etc/elasticsearch
RUN rm /srv/elastic/elasticsearch-7.16.3-amd64.deb
RUN echo "service elasticsearch start" > start.sh
RUN chmod +x start.sh
CMD bash start.sh ; /bin/sh
EXPOSE 9200


