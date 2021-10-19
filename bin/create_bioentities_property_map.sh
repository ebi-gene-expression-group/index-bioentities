#!/usr/bin/env bash

jar_dir=$CONDA_PREFIX/share/atlas-cli/build/libs
scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/common_routines.sh

require_env_var "SOLR_HOST"
require_env_var "SOLR_PORT"
require_env_var "ZK_HOST"
require_env_var "ZK_PORT"
require_env_var "BIOENTITIES"
require_env_var "SPECIES"

java_opts="-Dsolr.host=$SOLR_HOST"
java_opts="$java_opts -Dsolr.port=$SOLR_PORT"
java_opts="$java_opts -Dzk.host=$ZK_HOST"
java_opts="$java_opts -Dzk.port=$ZK_PORT"
java_opts="$java_opts -Ddata.files.location=$BIOENTITIES"

java $java_opts -jar $jar_dir/atlas-cli-bulk.jar \
bioentities-map -o ./bioentities/$SPECIES.map.bin -s $SPECIES
