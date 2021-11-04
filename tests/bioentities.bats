setup() {
  export SOLR_COLLECTION=bioentities-v1
}

@test "Check that curl is in the path" {
    run which curl
    [ "${status}" -eq 0 ]
}

@test "Check that awk is in the path" {
    run which awk
    [ "${status}" -eq 0 ]
}

@test "Check that jq is in the path" {
    run which jq
    [ "${status}" -eq 0 ]
}

@test "[bioentities] Create collection on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi
  if [ ! -z ${SOLR_COLLECTION_EXISTS+x} ]; then
    skip "Solr collection has been predifined on the current setup"
  fi
  run create-bioentities-collection.sh
  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "[bioentities] Load schema to collection on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi
  run create-bioentities-schema.sh
  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "[bioentities] Check that all fields are in the created schema" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping check of fields on schema"
  fi
  run bioentities-check-created-fields.sh
  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

#@test "[bioentities] Create JSONL file for human" {
#  export BIOENTITIES=
#}

@test "[bioentities] Load data to Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to Solr"
  fi
  export BIOENTITIES_TSV=$BATS_TEST_DIRNAME/fixtures/bioentity_properties/annotations/homo_sapiens.ensgene.tsv
  export PROPERTY_WEIGHTS_YAML=$BATS_TEST_DIRNAME/../property_weights.yaml
  run load-bioentities-collection.sh
  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "[bioentities] Check suggesters for bulk Expression Atlas have been properly created" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping suggesters check"
  fi
  run create-bioentities-suggesters-gxa.sh
  run bioentities-check-created-suggesters-gxa.sh
  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "[bioentities] Check suggesters for Single Cell Expression Atlas have been properly created" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping suggesters check"
  fi
  run create-bioentities-suggesters-scxa.sh
  run bioentities-check-created-suggesters-scxa.sh
  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "[bioentities] Check suggestions of known and unknown terms in bulk Expression Atlas" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping suggestions of known gene symbol"
  fi
  run create-bioentities-suggesters-gxa.sh
  run bioentities-check-suggestions-gxa.sh

  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "[bioentities] Check suggestions of known and unknown terms in Single Cell Expression Atlas" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping suggestions of known gene symbol"
  fi
  run create-bioentities-suggesters-scxa.sh
  run bioentities-check-suggestions-scxa.sh

  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "[bioentities] Create bioentities JSONL for human" {
  export output_dir=$( pwd )
  export SOLR_HOST=my_solr
  export SOLR_PORT=8983
  export CONDA_PREFIX=/opt/conda

  run create_bioentities_jsonl.sh


  echo "output = ${output}"
  [ "${status}" -eq 0 ]
  [ -f "$( pwd )/homo_sapiens.ensgene.jsonl" ]
}

@test "[bioentities] Load species into SOLR" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to Solr"
  fi

  if [ -z ${ORGANISM+x} ]; then
    skip "ORGANISM not defined, skipping load to solr"
  fi

  export BIOENTITIES_JSONL_PATH=$( pwd )

  run index_organism_annotations.sh

  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "[bioentities] Make mappings from bioentities for experiments" {
  # This will require adding some experiment files into tests/fixtures/experiment_files/magetab
  # that are compatible with the fixtures/bioentity_properties/homo_sapiens.ensgene.tsv
  # (this means that the gene identifiers match)
  export ACCESSIONS=E-MTAB-4754
  export SOLR_HOST=my_solr
  export SOLR_PORT=8983
  export CONDA_PREFIX=/opt/conda
  export output_dir=$( pwd )

  run create_bioentities_property_map.sh

  echo "output = ${output}"
  [ "${status}" -eq 0 ]
  [ -f "$( pwd )/homo_sapiens.map.bin" ]
  # Check that the mapping output exists
}
