#!/usr/bin/env bash
. ../schema-version.env

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"bioentities-v$SCHEMA_VERSION"}

echo "Retrieving fields in the schema"
curl "http://${HOST}/solr/${COLLECTION}/schema?wt=json" \
  | jq '.schema.fields + .schema.dynamicFields | .[].name ' | sed s/\"//g \
  | sort > bioentities_loaded_fields.txt

echo "Parsing creation script"
grep -A 2 '\("add-field"\|"add-dynamic-field"\)' "$(dirname "${BASH_SOURCE[0]}")"/../bin/create-bioentities-schema.sh \
  | grep '"name"' | awk -F':' '{ print $2 }' | sed 's/[\", ]//g' \
  | sort > bioentities_expected_loaded_fields.txt

echo "Running comm"
comm -13 bioentities_loaded_fields.txt bioentities_expected_loaded_fields.txt
