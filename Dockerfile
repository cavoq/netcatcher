FROM alpine:latest

RUN apk update && \
    apk add --no-cache openssh-client bash && \
    rm -rf /var/cache/apk/*

WORKDIR /netcatcher
COPY *.sh .env /netcatcher/

RUN chmod +x /netcatcher/*.sh
