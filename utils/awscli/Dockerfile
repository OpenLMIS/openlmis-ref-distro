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
RUN chmod u+x /entrypoint.sh
WORKDIR /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["sh"]
