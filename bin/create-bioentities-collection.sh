#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. ${DIR}/schema-version.env

set -e

# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"bioentities-v$SCHEMA_VERSION"}
BASE_CONFIG=${SOLR_BASE_CONFIG:-"_default"}

NUM_SHARDS=${SOLR_NUM_SHARDS:-1}
REPLICATION_FACTOR=${SOLR_REPLICATION_FACTOR:-1}
MAX_SHARDS_PER_NODE=${SOLR_MAX_SHARDS_PER_NODE:-1}

printf "\n\nDeleting collection ${COLLECTION} based on ${HOST}\n"
curl "http://${HOST}/solr/admin/collections?action=DELETE&name=${COLLECTION}"

printf "\n\nDelete config ${COLLECTION}\n"
curl "http://${HOST}/solr/admin/configs?action=DELETE&name=${COLLECTION}"

printf "\n\nCreating config based on ${BASE_CONFIG} for our collection\n"
curl "http://${HOST}/solr/admin/configs?action=CREATE&name=${COLLECTION}&baseConfigSet=${BASE_CONFIG}"

printf "\n\nCreating collection ${COLLECTION} based on ${HOST}\n"
curl "http://${HOST}/solr/admin/collections?action=CREATE&name=${COLLECTION}&numShards=${NUM_SHARDS}&replicationFactor=${REPLICATION_FACTOR}&maxShardsPerNode=$MAX_SHARDS_PER_NODE"

#############################################################################################

printf "\n\nDisabling auto-commit and soft auto-commit in ${COLLECTION}\n"
curl "http://${HOST}/solr/${COLLECTION}/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoCommit.maxTime":-1
  }
}'

curl "http://${HOST}/solr/${COLLECTION}/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoCommit.maxDocs":-1
  }
}'

curl "http://${HOST}/solr/${COLLECTION}/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoSoftCommit.maxTime":-1
  }
}'

curl "http://${HOST}/solr/${COLLECTION}/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoSoftCommit.maxDocs":-1
  }
}'
