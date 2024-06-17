FROM alpine

RUN apk add --update --no-cache postgresql-client

COPY configure.sh .
RUN chmod +x configure.sh
COPY data-connect-test-db.sql .


ENV POSTGRES_HOST="172.17.0.100:5432"
ENV POSTGRES_USERNAME="postgres"
ENV POSTGRES_PASSWORD="postgres"
ENV POSTGRES_PORT="5432"

ENV PSQL_CONNECTION_STRING="postgres://$POSTGRES_USERNAME:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/"

# SHELL ["/bin/sh", "-c"]
CMD echo $PSQL_CONNECTION_STRING
CMD ./configure.sh 
# ENTRYPOINT ["/bin/sh", "-c"]
# RUN /usr/bin/psql "postgres://$POSTGRES_USERNAME:$POSTGRES_PASSWORD@$POSTGRES_HOST/" -c "CREATE USER prestouser"
# CMD CREATE USER trinouser3;

