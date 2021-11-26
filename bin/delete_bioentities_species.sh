#!/usr/bin/env bash

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/common_routines.sh

require_env_var "SOLR_HOST"
require_env_var "SPECIES"

HTTP_STATUS=$(curl -o >(cat >&3) -w "%{http_code}" -X POST -H 'Content-Type: application/json' \
"http://$SOLR_HOST/solr/bioentities-v1/update/json?commit=true" --data-binary \
'{
  "delete": {
    "query": "species:$SPECIES"
  }
}')

if [[ ! ${HTTP_STATUS} == 2* ]]
then
  echo "Error during delete!" && exit 1
fi
