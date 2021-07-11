FROM alpine:edge

# RUN adduser -S mosquitto

# RUN apk add --no-cache mosquitto-clients su-exec

# COPY ./entrypoint-mosquitto-sub.sh /
# EXPOSE 1883 9001

COPY ./image/entrypoint.sh /entrypoint.sh

RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]