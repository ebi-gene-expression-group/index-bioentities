#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/../bin/schema-version.env

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"bioentities-v$SCHEMA_VERSION"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

echo "Checking suggesters in the schema"

for SUGGEST_DICTIONARY in propertySuggesterNoHighlight bioentitySuggester
do
  HTTP_STATUS=$(curl $SOLR_AUTH -s -w "%{http_code}" -o /dev/null "http://${HOST}/solr/${COLLECTION}/suggest?suggest.dictionary=${SUGGEST_DICTIONARY}")

  if [[ ! $HTTP_STATUS == 2* ]];
  then
    # HTTP Status is not a 2xx code, so it is an error.
    exit 1
  fi
done
