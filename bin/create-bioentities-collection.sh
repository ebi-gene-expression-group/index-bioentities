#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. ${DIR}/schema-version.env
. ${DIR}/common_routines.sh

# Exit on error and fail pipelines if any command fails
set -e
set -o pipefail

# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"
COLLECTION=${SOLR_COLLECTION:-"bioentities-v$SCHEMA_VERSION"}

NUM_SHARDS=${SOLR_NUM_SHARDS:-1}
REPLICATION_FACTOR=${SOLR_REPLICATION_FACTOR:-1}
MAX_SHARDS_PER_NODE=${SOLR_MAX_SHARDS_PER_NODE:-1}



# Default curl behavior: silent progress, show errors, fail on HTTP errors
CURL_OPTS="-sS --fail-with-body"

info "Deleting alias 'bioentities' if exists"
curl $CURL_OPTS $SOLR_AUTH "http://${HOST}/solr/admin/collections?action=DELETEALIAS&name=bioentities" || warn "Alias delete may have been unnecessary"

info "Deleting collection ${COLLECTION} on ${HOST} (ignore if not exists)"
curl $CURL_OPTS $SOLR_AUTH "http://${HOST}/solr/admin/collections?action=DELETE&name=${COLLECTION}" || warn "Collection delete may have been unnecessary"

info "Creating collection ${COLLECTION} on ${HOST}"
curl $CURL_OPTS $SOLR_AUTH "http://${HOST}/solr/admin/collections?action=CREATE&name=${COLLECTION}&numShards=${NUM_SHARDS}&replicationFactor=${REPLICATION_FACTOR}&maxShardsPerNode=$MAX_SHARDS_PER_NODE" 
success "Collection ensured: ${COLLECTION}"
#############################################################################################

info "Disabling auto-commit and soft auto-commit in ${COLLECTION}"
curl $CURL_OPTS $SOLR_AUTH "http://${HOST}/solr/${COLLECTION}/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoCommit.maxTime":-1
  }
}'

curl $CURL_OPTS $SOLR_AUTH "http://${HOST}/solr/${COLLECTION}/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoCommit.maxDocs":-1
  }
}'

curl $CURL_OPTS $SOLR_AUTH "http://${HOST}/solr/${COLLECTION}/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoSoftCommit.maxTime":-1
  }
}'

curl $CURL_OPTS $SOLR_AUTH "http://${HOST}/solr/${COLLECTION}/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoSoftCommit.maxDocs":-1
  }
}' 

info "Creating alias 'bioentities' -> ${COLLECTION}"
curl $CURL_OPTS $SOLR_AUTH "http://${HOST}/solr/admin/collections?action=CREATEALIAS&name=bioentities&collections=bioentities-v$SCHEMA_VERSION" >/dev/null

success "created collection ${COLLECTION}"
