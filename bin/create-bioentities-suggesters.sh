#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. ${DIR}/schema-version.env

# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"
COLLECTION=${SOLR_COLLECTION:-"bioentities-v${SCHEMA_VERSION}"}

#############################################################################################

printf "\n\nCreate empty search component for suggesters if it does not exist...\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-searchcomponent": {
    "name": "suggest",
    "class": "solr.SuggestComponent"
  }
}' http://${HOST}/solr/${COLLECTION}/config

printf "\n\nClear suggester configuration for SCXA and GXA...\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "update-searchcomponent": {
    "name": "suggest",
    "class": "solr.SuggestComponent",
    "suggester": [
      {
        "name": "propertySuggester"
      },
      {
        "name": "bioentitySuggester"
      },
      {
        "name": "propertySuggesterNoHighlight"
      }
    ]
  }
}' http://${HOST}/solr/${COLLECTION}/config

printf "\n\nAdd suggester for GXA and SCXA...\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "update-searchcomponent": {
    "name": "suggest",
    "class": "solr.SuggestComponent",
    "suggester": [
      {
        "name": "propertySuggester",
        "indexPath": "propertySuggester",
        "lookupImpl": "AnalyzingInfixLookupFactory",
        "dictionaryImpl": "DocumentDictionaryFactory",
        "field": "property_value",
        "contextField": "species",
        "weightField": "property_weight",
        "payloadField": "property_name",
        "suggestAnalyzerFieldType": "text_en",
        "queryAnalyzerFieldType": "text_en",
        "buildOnStartup": "false"
      },
      {
        "name": "bioentitySuggester",
        "indexPath": "bioentitySuggester",
        "lookupImpl": "AnalyzingInfixLookupFactory",
        "dictionaryImpl": "DocumentDictionaryFactory",
        "field": "property_value",
        "contextField": "species",
        "weightField": "property_weight",
        "payloadField": "bioentity_identifier",
        "suggestAnalyzerFieldType": "text_en",
        "queryAnalyzerFieldType": "text_en",
        "buildOnStartup": "false"
      },
      {
        "name": "propertySuggesterNoHighlight",
        "indexPath": "propertySuggesterNoHighlight",
        "lookupImpl": "AnalyzingInfixLookupFactory",
        "dictionaryImpl": "DocumentDictionaryFactory",
        "field": "property_value",
        "contextField": "species",
        "weightField": "property_name_id_weight",
        "payloadField": "property_name",
        "suggestAnalyzerFieldType": "text_en",
        "queryAnalyzerFieldType": "text_en",
        "highlight": "false",
        "buildOnStartup": "false"
      }
    ]
  }
}' http://${HOST}/solr/${COLLECTION}/config

#############################################################################################

printf "\n\nDelete request handler /suggest...\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-requesthandler" : "/suggest"
}' http://${HOST}/solr/${COLLECTION}/config

printf "\n\nCreate request handler /suggest...\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-requesthandler" : {
    "name": "/suggest",
    "class": "solr.SearchHandler",
    "startup": "lazy",
    "defaults":
      {
        "suggest": "true",
        "suggest.count": 100
      },
    "components": ["suggest"]
  }
}' http://${HOST}/solr/${COLLECTION}/config
