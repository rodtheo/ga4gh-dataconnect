# fasp-hackathon-2022

This repository contains resources for Session 2A of the 2022 FASP Hackathon.

## Installing the Trino CLI

Executing `install-trino-cli.sh` will install the trino cli in /usr/local/bin.

## Running the Trino Docker Image

To run trino:
```
docker run -d -p 8080:8080 --name fasp-trino trinodb/trino
```

To gain a shell into the trino container:
```
docker exec -it fasp-trino /bin/bash
```

## Setting up a datasource
Start a postgres database:
```
docker run -d --name fasp-postgres -p 5432:5432 -e POSTGRES_PASSWORD=postgres postgres
export PGPASSWORD=postgres
```

Import some test data:
```
gsutil cp gs://dnastack-fasp-hackathon-2022/data-connect-test-db.sql .
psql -h localhost -U postgres -p 5432 -c "CREATE DATABASE \"pgp-dataset-service\""
psql -h localhost -U postgres -p 5432 -c "CREATE USER \"pgp-dataset-service\" WITH PASSWORD 'pgp-dataset-service'"
psql -h localhost -U postgres -p 5432 -c "GRANT ALL ON DATABASE \"pgp-dataset-service\" TO \"pgp-dataset-service\""
psql -h localhost -U postgres -p 5432 -c "CREATE USER trinouser3"
psql -h localhost -U postgres -p 5432 -c "CREATE USER prestouser"
psql -h localhost -U postgres -p 5432 -c "CREATE USER prestouser3"
psql -h localhost -U postgres -p 5432 -d "pgp-dataset-service" -f data-connect-test-db.sql
```

## Adding a postgres connector to Trino

Create a fasp.properties file:

```
connector.name=postgresql
connection-url=jdbc:postgresql://host.docker.internal/pgp-dataset-service
connection-user=pgp-dataset-service
connection-password=pgp-dataset-service
```

Copy the file into your docker container:
```
docker cp fasp.properties fasp-trino:/etc/trino/catalog
```

Restart trino:
```
docker restart fasp-trino
```

## Building and Running Data Connect

Acquire the source:
`git clone git@github.com:DNAstack/data-connect-trino.git`

Build the image (from within the data-connect-trino repository):
`./ci/build-docker-image data-connect-trino:latest data-connect-trino latest`

Create the database for Data Connect:
```
psql -h localhost -p 5432 -U postgres -c "CREATE DATABASE dataconnecttrino"
psql -h localhost -p 5432 -U postgres -d dataconnecttrino -c "CREATE USER \"dataconnecttrino\" WITH PASSWORD 'dataconnecttrino'"
psql -h localhost -p 5432 -U postgres -d dataconnecttrino -c "GRANT ALL ON DATABASE \"dataconnecttrino\" TO dataconnecttrino"
```

Running the image:
```
docker run --name fasp-data-connect -p 8089:8089 -e TRINO_DATASOURCE_URL=http://host.docker.internal:8080 -e SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/dataconnecttrino -e SPRING_PROFILES_ACTIVE=no-auth data-connect-trino:latest
```
