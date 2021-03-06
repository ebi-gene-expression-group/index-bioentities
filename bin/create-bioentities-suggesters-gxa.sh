#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. ${DIR}/schema-version.env

# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"bioentities-v${SCHEMA_VERSION}"}

#############################################################################################

printf "\n\nDelete request handler /suggest"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-searchcomponent" : "suggest"
}' http://${HOST}/solr/${COLLECTION}/config

printf "\n\nCreate search component for suggesters"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-searchcomponent": {
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
      }
    ]
  }
}' http://${HOST}/solr/${COLLECTION}/config

#############################################################################################

printf "\n\nDelete request handler /suggest"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-requesthandler" : "/suggest"
}' http://${HOST}/solr/${COLLECTION}/config

printf "\n\nCreate request handler /suggest"
curl -X POST -H 'Content-type:application/json' --data-binary '{
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
