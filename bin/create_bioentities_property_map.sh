#!/usr/bin/env bash

jar_dir=$CONDA_PREFIX/share/atlas-cli
scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/common_routines.sh

require_env_var "SOLR_HOST"
require_env_var "SOLR_PORT"
require_env_var "ZK_HOST"
require_env_var "ZK_PORT"
require_env_var "BIOENTITIES"
require_env_var "ORGANISM" || require_env_var "ACCESSIONS"
require_env_var "output_dir"

java_opts="-Dsolr.host=$SOLR_HOST"
java_opts="$java_opts -Dsolr.port=$SOLR_PORT"
java_opts="$java_opts -Dzk.host=$ZK_HOST"
java_opts="$java_opts -Dzk.port=$ZK_PORT"
java_opts="$java_opts -Ddata.files.location=$BIOENTITIES"
java_opts="$java_opts -Dexperiment.files.location=$EXPERIMENT_FILES"
java_opts="$java_opts -Djdbc.url=$jdbc_url"
java_opts="$java_opts -Djdbc.username=$jdbc_username"
java_opts="$java_opts -Djdbc.password=$jdbc_password"
java_opts="$java_opts -Dserver.port=$server_port"

cmd="java $java_opts -jar $jar_dir/atlas-cli-bulk.jar"
cmd=$cmd" bioentities-map -o $output_dir/$ORGANISM.map.bin "

status=0
if [ -z ${ACCESSIONS+x} ]; then
  # we have no accessions, run with ORGANISM
  $cmd -s $ORGANISM
  status=$?
else
  # we run for specific accessions
  $cmd -e $ACCESSIONS
  status=$?
fi

exit $status
