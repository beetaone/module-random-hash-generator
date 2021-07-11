FROM alpine:edge

RUN apk --no-cache add curl

# EXPOSE 1883 9001

COPY ./image/entrypoint.sh /entrypoint.sh

RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]