FROM openlmis/dev:3

COPY entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh
COPY sql /sql

WORKDIR /
ENTRYPOINT ["/entrypoint.sh"]
CMD /bin/sh
