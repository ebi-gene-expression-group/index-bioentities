#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})
export PATH=${DIR}/../bin:${DIR}/../tests:${PATH}

# For java cli
export ZK_HOST=${ZK_HOST:localhost}
export ZK_PORT=${ZK_PORT:-2181}
export BIOENTITIES=$DIR/fixtures/
export EXPERIMENT_FILES=$DIR/fixtures/experiment_files
export jdbc_url=$jdbc_url
export ORGANISM=homo_sapiens
export jdbc_username=$POSTGRES_USER
export jdbc_password=$POSTGRES_PASSWORD
export server_port=8081 #fake
