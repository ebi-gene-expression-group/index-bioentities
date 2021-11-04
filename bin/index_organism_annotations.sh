#!/usr/bin/env bash

# Index an organism annotations

jar_dir=$CONDA_PREFIX/share/atlas-cli/build/libs

require_env_var "SOLR_HOST"
require_env_var "ORGANISM"


for FILE in ./bioentities/mus_musculus.*
do
  INPUT_JSONL=$FILE SOLR_COLLECTION=bioentities SCHEMA_VERSION=1 ./bin/solr-jsonl-chunk-loader.sh
done
