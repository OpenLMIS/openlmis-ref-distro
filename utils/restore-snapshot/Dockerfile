FROM openlmis/awscli

COPY restore-snapshot.sh /app/restore-snapshot.sh
RUN chmod u+x /app/restore-snapshot.sh

CMD /app/restore-snapshot.sh
