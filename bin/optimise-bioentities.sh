#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. ${DIR}/schema-version.env

# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"bioentities-v${SCHEMA_VERSION}"}

echo "Optimising bioentities..."
# creates a new file descriptor 3 that redirects to 1 (STDOUT)
exec 3>&1

HTTP_STATUS=$(curl -w "%{http_code}" -o >(cat >&3) -s "http://${HOST}/solr/${COLLECTION}/update?optimize=true")

if [[ ! $HTTP_STATUS == 2* ]];
then
	 # HTTP Status is not a 2xx code
   exit 1
fi
