#!/usr/bin/env bash

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

[ -z ${ATLASPROD_PATH+x} ] && echo "Env var ATLASPROD_PATH for the path to atlas prod software check out needs to be defined." && exit 1
[ ! -z ${TOMCAT_HOST_USERNAME+x} ] || ( echo "Env var TOMCAT_HOST_USERNAME ie. curator needs to be defined." && exit 1 )
[ ! -z ${TOMCAT_HOST_PASSWORD+x} ] || ( echo "Env var TOMCAT_HOST_PASSWORD needs to be defined." && exit 1 )
[ ! -z ${TOMCAT_HOST+x} ] || ( echo "Env var TOMCAT_HOST ie. ves:8080 needs to be defined." && exit 1 )


# Set path (this is done at this level since this will be executed directly):
for mod in index-bioentities/bin; do
  export PATH=$ATLASPROD_PATH/$mod:$PATH
done

checkExecutableInPath() {
  [[ $(type -P $1) ]] || (echo "$1 binaries not in the path." && exit 1)
  [[ -x $(type -P $1) ]] || (echo "$1 is not executable." && exit 1)
}

# start indexing
echo "Started bioentities indexing ..."
curl -s -u ${TOMCAT_HOST_USERNAME}:${TOMCAT_HOST_PASSWORD} "http://${TOMCAT_HOST}/gxa/admin/bioentitiesIndex/buildIndex"

## wait for a moment to start indexing and check status
sleep 10;
status=""
status=$(curl -s -u ${TOMCAT_HOST_USERNAME}:${TOMCAT_HOST_PASSWORD} "http://${TOMCAT_HOST}/gxa/admin/bioentitiesIndex/buildIndex/status" | head -n1 | awk -F',' '{ print $1 }')
echo "status : ${status}"

## check if indexing has completed
while [ "${status}" == 'PROCESSING' ];
do
    echo "status : ${status}"
    status=$(curl -s -u ${TOMCAT_HOST_USERNAME}:${TOMCAT_HOST_PASSWORD} "http://${TOMCAT_HOST}/gxa/admin/bioentitiesIndex/buildIndex/status" | head -n1 | awk -F',' '{ print $1 }')  2> /dev/null 1> /dev/null
    if [ "${status}" == 'PROCESSING' ]; then
        sleep 60
        continue
    elif [ "${status}" == 'COMPLETED' ]; then
        echo "Bioentities indexing completed. status : ${status}"
        break
    elif [ "${status}" == 'FAILED' ]; then
        echo "Bioentities indexing failed. status : ${status}"
        exit 1
    fi
done
