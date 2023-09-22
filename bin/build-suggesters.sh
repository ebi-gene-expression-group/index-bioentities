#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. ${DIR}/schema-version.env

# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"bioentities-v${SCHEMA_VERSION}"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

echo "Building bioentities scxa and gxa suggesters..."
# creates a new file descriptor 3 that redirects to 1 (STDOUT)
exec 3>&1 

#status=0
for suggester in propertySuggesterNoHighlight bioentitySuggester propertySuggester; do
  HTTP_STATUS=$(curl $SOLR_AUTH -w "%{http_code}" -o >(cat >&3) -s "http://${HOST}/solr/${COLLECTION}/suggest?suggest.dictionary=${suggester}&suggest.build=true")

  if [[ ! $HTTP_STATUS == 2* ]];
  then
	   # HTTP Status is not a 2xx code
     echo "Failed to build suggester $suggester"
#     status=1
  fi
done

#exit $status
