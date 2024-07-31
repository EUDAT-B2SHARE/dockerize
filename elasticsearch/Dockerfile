FROM elasticsearch:2.4.6
EXPOSE 9200 9300

COPY log4j-1.2.17.jar /usr/share/elasticsearch/lib/log4j-1.2.17.jar
RUN cd /usr/share/elasticsearch && \
    ./bin/plugin install -b mapper-attachments

CMD ["elasticsearch"]
