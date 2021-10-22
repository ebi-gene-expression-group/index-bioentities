#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})
export PATH=${DIR}/../bin:${DIR}/../tests:${PATH}

# For java cli
export ZK_HOST=localhost # fake
export ZK_PORT=8777 # fake
export BIOENTITIES=$DIR/fixtures/
export EXPERIMENT_FILES=$DIR/fixtures/experiment_files
export jdbc_url="jdbc:postgresql://postgres:5432/scxa-test"
export jdbc_username=scxa
export jdbc_password=postgresPass
export server_port=8081 #fake
