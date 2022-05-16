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


NUM_SUGGESTIONS=$(curl $SOLR_AUTH -s \
  "http://${HOST}/solr/${COLLECTION}/suggest?suggest.dictionary=propertySuggesterNoHighlight&suggest.q=pseudo" | \
  jq '.suggest.propertySuggesterNoHighlight.pseudo.numFound')
if ((! ${NUM_SUGGESTIONS} > 0 ))
then
  exit 1
fi

NUM_SUGGESTIONS=$(curl $SOLR_AUTH -s \
  "http://${HOST}/solr/${COLLECTION}/suggest?suggest.dictionary=propertySuggesterNoHighlight&suggest.q=foobar" | \
  jq '.suggest.propertySuggesterNoHighlight.foobar.numFound')
if (( ${NUM_SUGGESTIONS} != 0 ))
then
  exit 1
fi

NUM_SUGGESTIONS=$(curl $SOLR_AUTH -s \
  "http://${HOST}/solr/${COLLECTION}/suggest?suggest.dictionary=bioentitySuggester&suggest.q=ENSG" | \
  jq '.suggest.bioentitySuggester.ENSG.numFound')
if ((! ${NUM_SUGGESTIONS} > 0 ))
then
  exit 1
fi

NUM_SUGGESTIONS=$(curl $SOLR_AUTH -s \
  "http://${HOST}/solr/${COLLECTION}/suggest?suggest.dictionary=bioentitySuggester&suggest.q=foobar" | \
  jq '.suggest.bioentitySuggester.foobar.numFound')
if (( ${NUM_SUGGESTIONS} != 0 ))
then
  echo "Found num suggestions $NUM_SUGGESTIONS instead of >0."
  exit 1
fi
