
PSQL_CONNECTION_STRING="postgres://postgres:postgres@fasp-postgres/"
PSQL_CONNECTION_STRING_DC="postgres://postgres:postgres@fasp-postgres/dataconnecttrino"
PSQL_CONNECTION_STRING_DS="postgres://postgres:postgres@fasp-postgres/pgp-dataset-service"

psql $PSQL_CONNECTION_STRING -c "CREATE DATABASE \"pgp-dataset-service\""
psql $PSQL_CONNECTION_STRING -c "CREATE USER \"pgp-dataset-service\" WITH PASSWORD 'pgp-dataset-service'"
psql $PSQL_CONNECTION_STRING -c "GRANT ALL ON DATABASE \"pgp-dataset-service\" TO \"pgp-dataset-service\""
psql $PSQL_CONNECTION_STRING -c "CREATE USER trinouser3"
psql $PSQL_CONNECTION_STRING -c "CREATE USER prestouser"
psql $PSQL_CONNECTION_STRING -c "CREATE USER prestouser3"
psql $PSQL_CONNECTION_STRING_DS  -f data-connect-test-db.sql
# psql $PSQL_CONNECTION_STRING -c "CREATE USER \"dataconnecttrino\" PASSWORD 'dataconnecttrino' CREATEDB CREATEROLE"
# psql $PSQL_CONNECTION_STRING -c "CREATE DATABASE dataconnecttrino OWNER dataconnecttrino"
psql $PSQL_CONNECTION_STRING -c "CREATE DATABASE dataconnecttrino"
psql $PSQL_CONNECTION_STRING_DC  -c "CREATE USER \"dataconnecttrino\" WITH PASSWORD 'dataconnecttrino'"
psql $PSQL_CONNECTION_STRING_DC  -c "GRANT ALL ON DATABASE \"dataconnecttrino\" TO dataconnecttrino"
psql $PSQL_CONNECTION_STRING  -c "ALTER DATABASE \"dataconnecttrino\" OWNER TO dataconnecttrino"
