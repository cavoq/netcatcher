FROM alpine:latest

RUN apk update && \
    apk add --no-cache openssh-client sshpass bash tshark dcron && \
    rm -rf /var/cache/apk/*

WORKDIR /netcatcher

COPY *.sh /netcatcher/
COPY scripts/*.sh /netcatcher/scripts/
COPY jobs.cron /etc/cron.d/jobs.cron

RUN chmod 0744 /netcatcher/scripts/*.sh
RUN chmod 0744 /netcatcher/*.sh

EXPOSE 22

RUN chmod 0644 /etc/cron.d/jobs.cron && \
    crontab /etc/cron.d/jobs.cron
 
CMD crond -f
