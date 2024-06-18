# setup data connect trino dependencies
setup-infra:
    cd data-connect-trino && ./ci/build-docker-image data-connect-trino:latest data-connect-trino latest
    docker-compose -f dataconnect-compose.yaml up -d

# setup data connect trino dependencies using HTTPS
setup-infra-https:
    cd data-connect-trino && ./ci/build-docker-image data-connect-trino:latest data-connect-trino latest
    docker-compose -f dataconnect-compose-security.yaml up -d

setdown-infra:
    docker-compose -f dataconnect-compose.yaml down

setdown-infra-https:
    docker-compose -f dataconnect-compose-security.yaml down

# configure postgress trino plugin properties
setup-config:
    docker cp fasp.properties ga4gh-dataconnect_fasp-trino_1:/etc/trino/catalog
    docker-compose -f dataconnect-compose.yaml restart

setup-config-security:
    docker cp fasp.properties fasp-hackathon-2022_fasp-trino_1:/etc/trino/catalog
    docker-compose -f dataconnect-compose-security.yaml restart

setup-all: setup-infra setup-config

# add the one thousand sample data developed in GA4GH DataConnect Starter Kit tutorial
add-1000G:
    export PGPASSWORD=postgres
    psql -h localhost -U postgres -p 5432 -d "pgp-dataset-service" -f database/one_thousand_sample/create-tables.sql
    psql -h localhost -U postgres -p 5432 -d "pgp-dataset-service" -f database/one_thousand_sample/add-dev-dataset.sql
    psql -h localhost -U postgres -p 5432 -d "pgp-dataset-service" -c "GRANT SELECT ON one_thousand_genomes_sample  TO \"pgp-dataset-service\""
    psql -h localhost -U postgres -p 5432 -d "pgp-dataset-service" -c "GRANT SELECT ON phenopacket_v1  TO \"pgp-dataset-service\""

# add flight dataset (https://github.com/trinodb/trino-the-definitive-guide/tree/master/flight-data-set)
add-flight-dataset:
    export PGPASSWORD=postgres
    psql -h localhost -U postgres -p 5432 -c "CREATE DATABASE flight"
    psql -h localhost -U postgres -p 5432 -d flight -c "CREATE SCHEMA airline"
    psql -h localhost -U postgres -p 5432 -d flight -f database/flight_dataset/airport.sql
    psql -h localhost -U postgres -p 5432 -d flight -f database/flight_dataset/carrier.sql    
    docker cp database/flight_dataset/flightpostgresql.properties fasp-hackathon-2022_fasp-trino_1:/etc/trino/catalog
    docker cp database/flight_dataset/minio.properties fasp-hackathon-2022_fasp-trino_1:/etc/trino/catalog
    docker cp minio_hive/conf/core-site.xml hive-metastore:/opt/apache-hive-metastore-3.0.0-bin/conf
    docker-compose -f dataconnect-compose.yaml restart

# make sure you have installed phenopackets-tools
# https://github.com/phenopackets/phenopacket-tools/releases/download/v1.0.0-RC3/phenopacket-tools-cli-1.0.0-RC3-distribution.zip
# make sure you have python installed
setup-phenopackets-files-to-minio:
    mkdir -p database/phenopackets/v2
    bash database/phenopackets/convert.sh
    mkdir -p database/phenopackets/v2_single_line
    bash database/phenopackets/transform_to_json_single.sh

# make sure you have installed Minio MC client into a PATH directory
# wget https://dl.min.io/client/mc/release/linux-amd64/mc
# make sure you have installed phenopackets-tools
# https://github.com/phenopackets/phenopacket-tools/releases/download/v1.0.0-RC3/phenopacket-tools-cli-1.0.0-RC3-distribution.zip
mc-up-phenopackets:
    mc alias set dcminio http://localhost:9000 minio_user minio_password
    mc mb dcminio/test-pheno-v2
    mc cp database/phenopackets/v2_single_line/* dcminio/test-pheno-v2/
    docker cp database/flight_dataset/minio.properties fasp-hackathon-2022_fasp-trino_1:/etc/trino/catalog
    docker cp minio_hive/conf/core-site.xml hive-metastore:/opt/apache-hive-metastore-3.0.0-bin/conf
    docker cp database/phenopackets/trino_hive.trino fasp-hackathon-2022_fasp-trino_1:/home/trino
    docker exec fasp-hackathon-2022_fasp-trino_1 trino -f /home/trino/trino_hive.trino
    docker-compose -f dataconnect-compose.yaml restart

mc-down-phenopackets:
    mc rb --force dcminio/test-pheno-v2
    mc alias remove dcminio

create-cluster:
    kind create cluster --config k8s/kind.yaml --name genpla
    kubectl cluster-info --context kind-genpla

cluster-deployment:
    kubectl apply -f k8s/deployment.yaml
    kubectl get deployments

cluster-services-clusterip:
    kubectl apply -f k8s/service.yaml
    kubectl port-forward svc/trino-service 8080:8080
    kubectl get services

get-clusters:
    kubectl config get-clusters