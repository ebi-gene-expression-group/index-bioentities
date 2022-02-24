#!/usr/bin/env bash

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/common_routines.sh

require_env_var "SOLR_HOST"
require_env_var "SPECIES"

# creates a new file descriptor 3 that redirects to 1 (STDOUT)
exec 3>&1

HTTP_STATUS=$(curl -o >(cat >&3) -w "%{http_code}" -X POST -H "Content-Type: text/xml" \
"http://$SOLR_HOST/solr/bioentities-v1/update?commit=true" --data-binary \
"<delete><query>species:$SPECIES</query></delete>"
)

if [[ ! ${HTTP_STATUS} == 2* ]]
then
  echo "Error during delete!" && exit 1
fi
