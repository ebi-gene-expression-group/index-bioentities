#!/usr/bin/env bash
. ../schema-version.env

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"bioentities-v$SCHEMA_VERSION"}

echo "Checking suggesters..."

curl -s -o /dev/null "http://${HOST}/solr/${COLLECTION}/suggest?suggest.dictionary=propertySuggesterNoHighlight&suggest.build=true"
curl -s -o /dev/null "http://${HOST}/solr/${COLLECTION}/suggest?suggest.dictionary=bioentitySuggester&suggest.build=true"

NUM_SUGGESTIONS=$(curl -s \
  "http://${HOST}/solr/${COLLECTION}/suggest?suggest.dictionary=propertySuggesterNoHighlight&suggest.q=pseudo" | \
  jq '.suggest.propertySuggesterNoHighlight.pseudo.numFound')
if ((! ${NUM_SUGGESTIONS} > 0 ))
then
  exit 1
fi

NUM_SUGGESTIONS=$(curl -s \
  "http://${HOST}/solr/${COLLECTION}/suggest?suggest.dictionary=propertySuggesterNoHighlight&suggest.q=foobar" | \
  jq '.suggest.propertySuggesterNoHighlight.foobar.numFound')
if (( ${NUM_SUGGESTIONS} != 0 ))
then
  exit 1
fi

NUM_SUGGESTIONS=$(curl -s \
  "http://${HOST}/solr/${COLLECTION}/suggest?suggest.dictionary=bioentitySuggester&suggest.q=ENSG" | \
  jq '.suggest.bioentitySuggester.ENSG.numFound')
if ((! ${NUM_SUGGESTIONS} > 0 ))
then
  exit 1
fi

NUM_SUGGESTIONS=$(curl -s \
  "http://${HOST}/solr/${COLLECTION}/suggest?suggest.dictionary=bioentitySuggester&suggest.q=foobar" | \
  jq '.suggest.bioentitySuggester.foobar.numFound')
if (( ${NUM_SUGGESTIONS} != 0 ))
then
  exit 1
fi
