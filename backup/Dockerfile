FROM alpine

RUN apk add postgresql-client
RUN apk add dcron

COPY pgsqlbackup.sh /usr/local/bin/pgsqlbackup.sh
COPY drop_old_dumps.sh /usr/local/bin/drop_old_dumps.sh

ENV DB_NAME="b2share"
ENV DB_HOST="postgres"
ENV DB_PORT="5432"
ENV NUMBER_OF_DUMPS="30"

# Create cron job
COPY crontab /etc/cron.d/pgsqlbackup-cron
RUN chmod 0644 /etc/cron.d/pgsqlbackup-cron

RUN touch /test.txt

CMD crond -s /etc/cron.d -b && tail -f /test.txt

