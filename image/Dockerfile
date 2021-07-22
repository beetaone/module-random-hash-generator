FROM alpine:edge

RUN apk --no-cache add curl jq

# Oh yes, you need bash!
RUN apk add --no-cache bash
SHELL ["/bin/bash", "-c"]

COPY ./image/entrypoint.sh /entrypoint.sh
COPY ./image/main.sh /main.sh

RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]