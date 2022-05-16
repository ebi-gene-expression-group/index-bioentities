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

echo "Checking suggesters..."

HTTP_STATUS=$(curl $SOLR_AUTH -s -w "%{http_code}" -o /dev/null "http://${HOST}/solr/${COLLECTION}/suggest?suggest.dictionary=propertySuggester")

if [[ ! ${HTTP_STATUS} == 2* ]];
then
  # HTTP Status is not a 2xx code, so it is an error.
  exit 1
fi
