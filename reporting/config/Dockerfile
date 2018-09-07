FROM gliderlabs/alpine:3.4

COPY ./services /config

RUN apk add --update curl && rm -rf /var/cache/apk/*

CMD /bin/true