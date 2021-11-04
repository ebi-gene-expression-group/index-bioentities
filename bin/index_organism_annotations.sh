#!/usr/bin/env bash

# Index an organism annotations.
scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/common_routines.sh

require_env_var "SOLR_HOST"
require_env_var "ORGANISM"
require_env_var "BIOENTITIES_JSONL_PATH"

failed=0

for FILE in $BIOENTITIES_JSONL_PATH/${ORGANISM}.*
do
  INPUT_JSONL=$FILE SOLR_COLLECTION=bioentities SCHEMA_VERSION=1 solr-jsonl-chunk-loader.sh
  if [ $? -ne 0 ]; then
    echo "Loading JSONL to $SOLR_HOST failed for $FILE"
    failed=1
  fi
done

exit $failed
