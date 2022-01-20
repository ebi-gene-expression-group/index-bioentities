#!/usr/bin/env bash

export SOLR_HOST=my_solr:8983
export ZK_HOST=gxa-zk-1
export ZK_PORT=2181
export POSTGRES_HOST=postgres
export POSTGRES_DB=gxa
export POSTGRES_USER=gxa
export POSTGRES_PASSWORD=postgresPass
export POSTGRES_PORT=5432
export jdbc_url="jdbc:postgresql://$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"

docker network create mynet
docker run --rm --net mynet --name $ZK_HOST -d -p $ZK_PORT:$ZK_PORT -e ZOO_MY_ID=1 -e ZOO_SERVERS='server.1=0.0.0.0:2888:3888' -t zookeeper:3.4.14
docker run --rm --net mynet --name my_solr -d -p 8983:8983 -e ZK_HOST=$ZK_HOST:$ZK_PORT -t solr:7.1-alpine -Denable.runtime.lib=true -DzkRun -m 500m
# For atlas-web-bulk-cli application context
docker run --rm --net mynet --name $POSTGRES_HOST \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_DB=$POSTGRES_DB \
  -p $POSTGRES_PORT:$POSTGRES_PORT -d postgres:10.3-alpine

sleep 10s

# Setup the database schema
if [ ! -d "atlas-schemas" ]; then
  rm -rf ebi-gene-expression-group-atlas-schemas*
  wget https://github.com/ebi-gene-expression-group/atlas-schemas/tarball/master -O - | tar -xz
  mv ebi-gene-expression-group-atlas-schemas* atlas-schemas
fi
docker run --rm -i --net mynet \
  -v $( pwd )/atlas-schemas/flyway/gxa:/flyway/gxa \
  quay.io/ebigxa/atlas-schemas-base:1.0 \
  flyway migrate -url=$jdbc_url -user=$POSTGRES_USER -password=$POSTGRES_PASSWORD -locations=filesystem:/flyway/gxa

# Add experiment to database
docker run --rm -i --net mynet \
  -v $( pwd )/tests/load_experiment_query.sh:/tmp/load_experiment_query.sh \
  -e PGPASSWORD=$POSTGRES_PASSWORD \
  -e PGUSER=$POSTGRES_USER \
  -e PGDATABASE=$POSTGRES_DB \
  -e PGPORT=$POSTGRES_PORT \
  -e PGHOST=$POSTGRES_HOST \
  quay.io/ebigxa/atlas-schemas-base:1.0 \
  /tmp/load_experiment_query.sh E-MTAB-4754 RNASEQ_MRNA_BASELINE 'Homo sapiens'

docker run --rm -i --net mynet \
  -v $( pwd )/tests:/usr/local/index-bioentities/tests \
  -v $( pwd )/bin:/usr/local/index-bioentities/bin \
  -v $( pwd )/property_weights.yaml:/usr/local/index-bioentities/property_weights.yaml \
  -e SOLR_HOST=$SOLR_HOST \
  -e ZK_HOST=$ZK_HOST \
  -e ZK_PORT=$ZK_PORT \
  -e jdbc_url=$jdbc_url \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  --entrypoint=/usr/local/index-bioentities/tests/run-tests.sh quay.io/ebigxa/atlas-index-base:1.4

# docker stop my_solr
# docker network rm mynet
