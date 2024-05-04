FROM alpine:latest

ARG SERVER_ADDRESS=localhost
ARG SERVER_PORT=22
ARG SERVER_USER=root

RUN apk update && \
    apk add --no-cache openssh-client bash && \
    rm -rf /var/cache/apk/*

WORKDIR /netcatcher
COPY *.sh .env /netcatcher/

RUN chmod +x /netcatcher/*.sh

ENV SERVER_ADDRESS=$SERVER_ADDRESS \
    SERVER_PORT=$SERVER_PORT \
    SERVER_USER=$SERVER_USER

