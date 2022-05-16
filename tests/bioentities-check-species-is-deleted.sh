#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/../bin/schema-version.env

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"bioentities-v$SCHEMA_VERSION"}
SOLR_USER=${QUERY_USER:-"solr"}
SOLR_PASS=${QUERY_U_PWD:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"


NUM_DOCS=$(curl $SOLR_AUTH -s \
  "http://${HOST}/solr/${COLLECTION}/select?q=species:$SPECIES" | \
  jq '.response.numFound')
if (( ${NUM_DOCS} > 0 ))
then
  echo "Documents found when querying for species $SPECIES, it should be empty after a succesful deletion."
  exit 1
fi
