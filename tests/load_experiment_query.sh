#!/usr/bin/env bash

expAccession=$1
type=$2
species=$3
access_key=$(tr -dc A-Za-z0-9\- </dev/urandom | head -c 36)

psql <<EOF
DELETE FROM experiment WHERE accession = '$expAccession';
INSERT INTO experiment (accession, type, species, access_key)
VALUES ('$expAccession', '$type', '$species', '$access_key');
EOF
