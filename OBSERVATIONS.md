## Installing the Data Connect using Trino as backend

## Running the Trino Docker Image

First checkout git into commit: `commit 2dc1606517f7b725d1603722ac9f9d642c80ce7b`.
commit 88b126de7942730a759832023a7690d30c6a2c32

Because the newer commit is giving error when executing dataconnect.

To run trino:
```
docker run -d -p 8080:8080 --name fasp-trino trinodb/trino
```

To gain a shell into the trino container:
```
docker exec -it fasp-trino /bin/bash
```

## Running Trino in HTTPS with reverse proxy (nginx)

In order to access the Trino over domain name (pre-requisite to access through https), we need to make an entry in the /etc/hosts files and add the following at the end of the file - 127.0.0.1 my-trino.local. After this, now we should be able to access - http://my-trino.local:8080 in browser.

In order to have HTTPS in the local development environment, we will use a utility called [mkcert](https://github.com/FiloSottile/mkcert). In order to have mkcert, we first need to install the dependency - `libnss3-tools`. Open a terminal and run - sudo apt install libnss3-tools -y. Now lets download the pre-built mkcert binary from the github releases page. Download the appropriate binary. Since I am using Ubuntu on my develoment machine, so I will use mkcert-v1.4.3-linux-amd64. Download the binary file and move it to /usr/local/bin. We also need to make the file executable - chmod +x mkcert-v1.4.3-linux-amd64. Now lets create a softlink with name - mkcert - ln -s mkcert-v1.4.3-linux-amd64 mkcert. The first step is to become a valid Certificate Authority for local machine - mkcert -install. This will install the root CA for local machine.

Now lets get back to generating self-signed SSL certificates. Lets move back to our development folder `trino-dataconnect`. Here we will create directory `proxy` and inside it `certs` and `conf`. Lets move inside `proxy/certs` and generate the certificates.

```
(base) rodtheo@rodtheo-helios:~/Bioinfo/GA4GH/DataConnect/fasp-hackathon-2022/proxy/certs$ mkcert-v1.4.4-linux-amd64 -cert-file my-trino.local.crt -key-file my-trino.local.key my-trino.local

Created a new certificate valid for the following names 📜
 - "my-trino.local"

The certificate is at "my-trino.local.crt" and the key at "my-trino.local.key" ✅

It will expire on 6 September 2026 🗓
```

This will generate the SSL key and certificate file which is valid for domain - my-trino.local. Now lets modify the contents of file `dataconnect-compose-security.yaml` to use nginx as the proxy. Add the following contents under services tag.

```
services:
  proxy:
    image: nginx:1.19.10-alpine
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./proxy/conf/nginx.conf:/etc/nginx/nginx.conf
      - ./proxy/certs:/etc/nginx/certs
    networks:
      custom_net:
       ipv4_address: 10.5.0.15
```

source: https://dev.to/vishalraj82/using-https-in-docker-for-local-development-nc7

NOTE: mkcert can be use to generate ssl certificates for local development only. For production-ready environments please check: https://www.youtube.com/watch?v=J9jKKeV1XVE

## Running Trino in HTTPS setting Trino TSL

### Creating Java Keystores and Java Truststores

The Java keytool, a command-line tool for creating and managing keystores and
truststores, is available as part of any Java Development Kit (JDK) installation. Let’s
go over a simple example for creating a Java keystore and truststore. For simplicity,
we use self-signed certificates.

We strongly recommend obtaining a globally trusted certificate
from a vendor and using it on a load balancer in front of Trino or
directly with Trino. This avoids all certificate management and cre‐
ation discussed in this section. No certificate management on the
client is needed, because the certificate is globally trusted, including
the operating system, web browser, and runtime environments like
the JVM.



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

## 

```
SHOW CATALOGS;
SHOW SCHEMAS FROM fasp;
SHOW TABLES FROM fasp.public;
SHOW TABLES FROM fasp.ontology;

SELECT * FROM fasp.ontology.axiom LIMIT 10;

SELECT * FROM fasp.public.participant WHERE blood_type != '' LIMIT 10;

SHOW TABLES FROM fasp.public;

SELECT id, CASE WHEN blood_type = '' then null
ELSE CAST(ROW(
CASE regexp_extract(blood_type, '(\w+)([+-])', 1)
      when '0' then 'HP:0032442' -- source data has '0' where it should have 'O'
      when 'O' then 'HP:0032442'
      when 'A' then 'HP:0032370'
      when 'B' then 'HP:0032440'
      when 'AB' then 'HP:0032441'
      else 'error'
end,
case regexp_extract(blood_type, '(\w+)([+-])', 1)
      when '0' then 'O'
      else regexp_extract(blood_type, '(\w+)([+-])', 1)
end
)
as row(id varchar, label varchar)) 
end as blood_group
FROM fasp.public.participant;


SELECT * FROM fasp.public.phenopacket_v1 LIMIT 10;

SELECT pp.id, g.gene
FROM fasp.public.phenopacket_v1 pp,
UNNEST(CAST(json_extract(pp.json_data, '$.genes') as ARRAY(json))) AS g(gene);

SELECT pp.id, json_extract(g.gene, '$.id') as gene_id, json_extract(g.gene, '$.symbol') as gene_symbol
FROM fasp.public.phenopacket_v1 pp,
UNNEST(CAST(json_extract(pp.json_data, '$.genes') as ARRAY(json))) AS g(gene);

WITH pp_genes AS (
SELECT pp.id, json_extract(g.gene, '$.id') as gene_id, json_extract(g.gene, '$.symbol') as gene_symbol
FROM fasp.public.phenopacket_v1 pp,
UNNEST(CAST(json_extract(pp.json_data, '$.genes') as ARRAY(json))) AS g(gene)
) SELECT pp_genes.* FROM pp_genes WHERE CAST(gene_symbol AS VARCHAR) LIKE 'BB%';

```

```
SHOW CATALOGS;
SHOW SCHEMAS FROM minio;
SHOW TABLES FROM minio.bucket;
-- CREATE SCHEMA minio.bucket WITH (location = 's3a://test-bucket/');
SELECT * FROM minio.bucket.flights_c LIMIT 50;
-- SELECT * FROM minio.bucket.flights_csv WHERE year="2024" LIMIT 10;
-- SELECT * FROM minio.dadosdeprodutos.indicadoresProdutos;
-- CREATE SCHEMA minio.test WITH (location = 's3a://test-bucket/');
-- SELECT avg(TRY_CAST(depdelayminutes AS INT)) AS delay, year
-- FROM minio.bucket.flights_csv GROUP BY year
-- ORDER BY year DESC;

SELECT avg(CAST(depdelayminutes AS DOUBLE)) AS delay, year FROM minio.bucket.flights_c WHERE depdelayminutes != '' GROUP BY year
ORDER BY year DESC;

SELECT dayofweek, avg(CAST(depdelayminutes AS DOUBLE)) AS delay
FROM minio.bucket.flights_c
WHERE CAST(month AS INT)=2 AND origincityname LIKE '%Boston%' AND depdelayminutes != ''
GROUP BY dayofweek ORDER BY dayofweek;

-- return the top 10 airline carriers with the most flights from the data
SELECT uniquecarrier, count(*) AS ct
FROM minio.bucket.flights_c
GROUP BY uniquecarrier
ORDER BY count(*) DESC
LIMIT 10;

-- table carrier in PostgreSQL provides a mapping of the airline code
-- to the more descriptive airline name
SHOW SCHEMAS FROM flightpostgresql;
SHOW TABLES FROM flightpostgresql.airline;
SELECT * FROM flightpostgresql.airline.carrier LIMIT 10;


-- query for the flights_orc table and
-- modify it to join with the data in the PostgreSQL carrier
SELECT f.uniquecarrier, c.description, count(*) AS ct
FROM minio.bucket.flights_c f,
flightpostgresql.airline.carrier c
WHERE c.code = f.uniquecarrier
GROUP BY f.uniquecarrier, c.description
ORDER BY count(*) DESC
LIMIT 10;

-- we want Trino to return the top 10 airports that had the most departures
SELECT origin, count(*) AS ct
FROM minio.bucket.flights_c
GROUP BY origin
ORDER BY count(*) DESC
LIMIT 10;

SELECT code, name, city
FROM flightpostgresql.airline.airport
LIMIT 10;

SELECT f.origin, c.name, c.city, count(*) AS ct
FROM minio.bucket.flights_c f,
    flightpostgresql.airline.airport c
WHERE c.code = f.origin
GROUP BY origin, c.name, c.city
ORDER BY count(*) DESC
LIMIT 10;

```
