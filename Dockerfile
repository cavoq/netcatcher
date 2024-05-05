FROM alpine:latest

RUN apk update && \
    apk add --no-cache openssh-client sshpass bash tshark && \
    rm -rf /var/cache/apk/*

WORKDIR /netcatcher

COPY *.sh .env /netcatcher/

RUN chmod +x /netcatcher/*.sh

EXPOSE 22