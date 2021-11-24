#!/usr/bin/env bash

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/common_routines.sh

require_env_var "SOLR_HOST"
require_env_var "SPECIES"

curl -X POST -H 'Content-Type: application/json' \
"http://$SOLR_HOST/solr/bioentities-v1/update/json?commit=true" --data-binary \
'{
  "delete": {
    "query": "species:$SPECIES"
  }
}'
