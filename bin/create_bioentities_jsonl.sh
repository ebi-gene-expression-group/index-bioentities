#!/usr/bin/env bash

jar_dir=$CONDA_PREFIX/share/atlas-cli
scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/common_routines.sh

require_env_var "SOLR_HOST"
require_env_var "ZK_HOST"
require_env_var "ZK_PORT"
require_env_var "BIOENTITIES"
require_env_var "output_dir"
require_env_var "EXPERIMENT_FILES"
require_env_var "jdbc_url"
require_env_var "jdbc_username"
require_env_var "jdbc_password"
require_env_var "server_port"

SOLR_PORT=$(get_port_from_hostport $SOLR_HOST)
SOLR_HOST=$(get_host_from_hostport $SOLR_HOST)

require_env_var "SOLR_PORT"

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

# This will index everything that it is available in $BIOENTITIES
# To do separate species, link files of specific species to a new directory
# and point it there.

java $java_opts -jar $jar_dir/atlas-cli-bulk.jar bioentities-json -o ${output_dir}/

# These scripts could be added to index-gxa
#cp scripts/delete_bioentities_species.sh $PREFIX/bin
#cp scripts/create_bioentities_jsonl.sh $PREFIX/bin
#cp scripts/load_bioentities_species.sh $PREFIX/bin
#cp scripts/create_species_bioentity_map.sh $PREFIX/bin
#cp scripts/create_studies_analytics_jsonl.sh $PREFIX/bin
#cp scripts/load_studies_analytics.sh $PREFIX/bin
