#!/usr/bin/env bash

export SOLR_HOST=my_solr:8983
export ZK_HOST=gxa-zk-1

docker network create mynet
docker run --rm --net mynet --name $ZK_HOST -d -p 2181:2181 -e ZOO_MY_ID=1 -e ZOO_SERVERS='server.1=0.0.0.0:2888:3888' -t zookeeper:3.4.14
docker run --rm --net mynet --name my_solr -d -p 8983:8983 -e ZK_HOST=$ZK_HOST:$ZK_PORT -t solr:7.1-alpine -Denable.runtime.lib=true -DzkRun -m 500m
# For atlas-web-bulk-cli application context
docker run --rm --name postgres --net mynet -e POSTGRES_PASSWORD=postgresPass -e POSTGRES_USER=scxa -e POSTGRES_DB=scxa-test -p 5432:5432 -d postgres:10.3-alpine
docker build -t test/index-bioentities-module .

sleep 10s
docker run --rm -i --net mynet -v $( pwd )/tests:/usr/local/tests -e SOLR_HOST=$SOLR_HOST -e ZK_HOST=$ZK_HOST -e ZK_PORT=$ZK_PORT --entrypoint=/usr/local/tests/run-tests.sh test/index-bioentities-module

# docker stop my_solr
# docker network rm mynet
