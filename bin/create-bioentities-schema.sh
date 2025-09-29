#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. ${DIR}/schema-version.env
. ${DIR}/common_routines.sh

set -e
set -o pipefail

# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"
COLLECTION=${SOLR_COLLECTION:-"bioentities-v${SCHEMA_VERSION}"}

#############################################################################################
# Default curl behavior: silent progress, show errors, fail on HTTP errors
CURL_OPTS="-sS --fail"

info "Delete field type text_en"
curl $CURL_OPTS $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field-type":
  {
    "name": "text_en"
  }
}' http://${HOST}/solr/${COLLECTION}/schema || warn "field type text_en delete may have been unnecessary"

info "Create field type text_en"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field-type": {
    "name": "text_en",
    "class": "solr.TextField",
    "positionIncrementGap": "100",
    "analyzer" : {
      "tokenizer": {
        "class":"solr.WhitespaceTokenizerFactory"
      },
      "filters":[
        {
          "class":"solr.LowerCaseFilterFactory"
        },
        {
          "class":"solr.EnglishPossessiveFilterFactory"
        },
        {
          "class":"solr.PorterStemFilterFactory"
        }
      ]
    }
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "delete copy-field bioentity_identifier_dv"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-copy-field":{
     "source": "bioentity_identifier",
     "dest": "bioentity_identifier_dv"
   }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Delete field bioentity_identifier"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name":"bioentity_identifier"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field bioentity_dientifier (lowercase)"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name":"bioentity_identifier",
    "type":"lowercase"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Delete field bioentity_identifier_dv"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name":"bioentity_identifier_dv"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "\create field bioentity_identifier_dv"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
     "name": "bioentity_identifier_dv",
     "type": "string"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "\create copy-field bioentity_identifier_dv"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":{
     "source": "bioentity_identifier",
     "dest": "bioentity_identifier_dv"
   }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field bioentity_type"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name":"bioentity_type"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field bioentity_type (lowercase)"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name":"bioentity_type",
    "type":"lowercase"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete copy-field property_name_dv"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-copy-field":{
     "source": "property_name",
     "dest": "property_name_dv"
   }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Delete field property_name"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name":"property_name"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field property_name (lowercase)"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name":"property_name",
    "type":"lowercase"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Delete field property_name_dv"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name":"property_name_dv"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field property_name_dv"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
     "name": "property_name_dv",
     "type": "string"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create copy-field property_name_dv"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":{
     "source": "property_name",
     "dest": "property_name_dv"
   }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete copy-field property_value"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-copy-field":{
     "source": "property_value",
     "dest": "property_value_dv"
   }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Delete field property_value"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name":"property_value"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field property_value (text_en)"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name":"property_value",
    "type":"text_en"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field property_value_dv"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
     "name": "property_value_dv",
     "type": "string"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create copy-field property_value (text_en)"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":{
     "source": "property_value",
     "dest": "property_value_dv"
   }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete copy-field species_dev (lowercase)"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-copy-field":{
     "source": "species",
     "dest": "species_dv"
   }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Delete field species"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name":"species"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field species (lowercase)"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name":"species",
    "type":"lowercase"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Delete field species_dv"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name":"species_dv"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field species_dev (lowercase)"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
     "name": "species_dv",
     "type": "string"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create copy-field species_dev (lowercase)"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":{
     "source": "species",
     "dest": "species_dv"
   }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field property_weight"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name":"property_weight"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field property_weight (pint)"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name":"property_weight",
    "type":"pint"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field property_name_id_weight"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name":"property_name_id_weight"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field property_name_id_weight (pdouble)"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name":"property_name_id_weight",
    "type":"pdouble",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema
