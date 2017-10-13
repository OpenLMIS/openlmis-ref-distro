FROM openlmis/dev:3

RUN apk -v --update add \
    python \
    py-pip \
    jq \
    && \
  pip install --upgrade awscli s3cmd python-magic && \
  apk -v --purge del py-pip && \
  rm /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod 500 /entrypoint.sh
VOLUME /app
WORKDIR /app
ENTRYPOINT ["/entrypoint.sh"]
CMD ["sh"]
