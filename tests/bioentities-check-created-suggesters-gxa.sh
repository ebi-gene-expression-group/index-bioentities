#!/usr/bin/env bash
. ../schema-version.env

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"bioentities-v$SCHEMA_VERSION"}

echo "Checking suggesters..."

HTTP_STATUS=$(curl -s -w "%{http_code}" -o /dev/null "http://${HOST}/solr/${COLLECTION}/suggest?suggest.dictionary=propertySuggester")

if [[ ! ${HTTP_STATUS} == 2* ]];
then
  # HTTP Status is not a 2xx code, so it is an error.
  exit 1
fi
