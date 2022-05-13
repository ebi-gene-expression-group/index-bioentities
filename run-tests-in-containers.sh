#!/usr/bin/env bash

export SOLR_HOST=my_solr:8983
SOLR_CONT_NAME=my_solr
SOLR_VERSION=8.7
export ZK_HOST=gxa-zk-1
export ZK_PORT=2181
ZK_VERSION=3.5.8
export POSTGRES_HOST=postgres
export POSTGRES_DB=gxa
export POSTGRES_USER=gxa
export POSTGRES_PASSWORD=postgresPass
export POSTGRES_PORT=5432
export DOCKER_NET=net-index-bioentities
export jdbc_url="jdbc:postgresql://$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"

docker_arch_line=""
if [ $( arch ) == "arm64" ]; then
    docker_arch_line="--platform linux/amd64"
    echo "Changing arch $docker_arch_line"
fi

docker stop $SOLR_CONT_NAME && docker rm $SOLR_CONT_NAME
docker stop $ZK_HOST && docker rm $ZK_HOST
docker network rm $DOCKER_NET
docker network create $DOCKER_NET

docker run --rm --net $DOCKER_NET --name $ZK_HOST \
  -d -p $ZK_PORT:$ZK_PORT \
  -e ZOO_MY_ID=1 \
  -e ZOO_SERVERS="server.1=$ZK_HOST:2888:3888;$ZK_PORT" \
  -t zookeeper:$ZK_VERSION

sleep 10
docker run --rm --net $DOCKER_NET --name $SOLR_CONT_NAME \
  -d -p 8983:8983 \
  -e ZK_HOST=$ZK_HOST:$ZK_PORT \
  -t solr:$SOLR_VERSION -c -m 500m
# For atlas-web-bulk-cli application context
docker run --rm --net $DOCKER_NET --name $POSTGRES_HOST \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_DB=$POSTGRES_DB \
  -p $POSTGRES_PORT:$POSTGRES_PORT -d postgres:10-alpine3.15

sleep 20

# Setup the database schema
if [ ! -d "atlas-schemas" ]; then
  rm -rf ebi-gene-expression-group-atlas-schemas*
  wget https://github.com/ebi-gene-expression-group/atlas-schemas/tarball/master -O - | tar -xz
  mv ebi-gene-expression-group-atlas-schemas* atlas-schemas
fi
docker run --rm -i --net $DOCKER_NET $docker_arch_line \
  -v $( pwd )/atlas-schemas/flyway/gxa:/flyway/gxa \
  quay.io/ebigxa/atlas-schemas-base:1.0 \
  flyway migrate -url=$jdbc_url -user=$POSTGRES_USER -password=$POSTGRES_PASSWORD -locations=filesystem:/flyway/gxa

# Add experiment to database
docker run --rm -i --net $DOCKER_NET $docker_arch_line \
  -v $( pwd )/tests/load_experiment_query.sh:/tmp/load_experiment_query.sh \
  -e PGPASSWORD=$POSTGRES_PASSWORD \
  -e PGUSER=$POSTGRES_USER \
  -e PGDATABASE=$POSTGRES_DB \
  -e PGPORT=$POSTGRES_PORT \
  -e PGHOST=$POSTGRES_HOST \
  quay.io/ebigxa/atlas-schemas-base:1.0 \
  /tmp/load_experiment_query.sh E-MTAB-4754 RNASEQ_MRNA_BASELINE 'Homo sapiens'

docker run --rm -i --net $DOCKER_NET $docker_arch_line \
  -v $( pwd )/tests:/usr/local/index-bioentities/tests \
  -v $( pwd )/bin:/usr/local/index-bioentities/bin \
  -v $( pwd )/property_weights.yaml:/usr/local/index-bioentities/property_weights.yaml \
  -e SOLR_HOST=$SOLR_HOST \
  -e ZK_HOST=$ZK_HOST \
  -e ZK_PORT=$ZK_PORT \
  -e jdbc_url=$jdbc_url \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  --entrypoint=/usr/local/index-bioentities/tests/run-tests.sh quay.io/ebigxa/atlas-index-base:1.5

# docker stop my_solr
# docker network rm $DOCKER_NET
