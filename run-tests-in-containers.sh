#!/usr/bin/env bash

export SOLR_HOST=my_solr:8983

docker network create mynet
docker run --rm --net mynet --name my_solr -d -p 8983:8983 -t solr:7.1-alpine -DzkRun -Denable.runtime.lib=true -m 500m
# For atlas-web-bulk-cli application context
docker run --name postgres --net mynet -e POSTGRES_PASSWORD=postgresPass -e POSTGRES_USER=scxa -e POSTGRES_DB=scxa-test -p 5432:5432 -d postgres:10.3-alpine
docker build -t test/index-bioentities-module .

sleep 10s
docker run --rm -i --net mynet -v $( pwd )/tests:/usr/local/tests -e SOLR_HOST=$SOLR_HOST --entrypoint=/usr/local/tests/run-tests.sh test/index-bioentities-module

# docker stop my_solr
# docker network rm mynet
