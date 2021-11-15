# `bioentities` collection v1

Scripts to automate building and populating the `bioentities` collection.

## Requirements

You won't need any of this if you use containers, which is the preferred way of running. See run-tests-with-containers.sh to see which containers to use. If you are not using containers, then keep on reading, otherwise skip to the next part of this document.

It is strongly recommended that the `bin` directory in the root of this repo is
added to the path.

The following executables should be available:
- awk
- jq (1.5+)
- curl
- Python 3 (with Pandas and PyYAML support) †

† Run `pip install pyyaml pandas`; you’ll need `g++` as some parts of Pandas
are optimised in Cython

## Create the collection
To create the collection and define its schema run (set `SOLR_HOST` to the
appropriate host and port):

```bash
export SOLR_HOST=localhost:8983

create-bioentities-collections.sh
create-bioentities-schema.sh
```

## Add suggesters
For bulk Expression Atlas run:
```bash
create-bioentities-suggesters-gxa.sh
```

For Single Cell Expression Atlas run:
```bash
create-bioentities-suggesters-scxa.sh
```

## Load data - web cli - current

This approach uses the atlas-web-cli JAR through conda, and is the most current setup. It first entails the creation of bioentities JSONL for a species and then loading it. This means that the process of creation of JSONLs can be distributed as much as possible, while queuing separately the later loading to avoid very high loads on the solr server. This unfortunately requires the setup of a large amount of environment variables for the application context of the web application. Note that this is not going through the actual Tomcat process of the web application, but through an independent execution (on each run) of the JAR file that contains the same code.

```bash
# here we show tests settings
export ZK_HOST=${ZK_HOST:localhost}
export ZK_PORT=${ZK_PORT:-2181}
export SOLR_HOST=my_solr:8983
export BIOENTITIES=$DIR/fixtures/
export EXPERIMENT_FILES=$DIR/fixtures/experiment_files
export jdbc_url="jdbc:postgresql://$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"
export jdbc_username=$POSTGRES_USER
export jdbc_password=$POSTGRES_PASSWORD
export server_port=8081 #fake

export output_dir=$( pwd )

# create JSONL
./bin/create_bioentities_jsonl.sh
# Load
export SPECIES=homo_sapiens
export BIOENTITIES_JSONL_PATH=$( pwd )

./bin/index_organism_annotations.sh
```

## Create mapping for analytics indexing

As in the previous step, this also uses the atlas-web-cli. It will take files in the bioentity_properties and experiment_files expected by the wen application and the data in the currently loaded bioentities in solr
to create mapping files from the expression data to the bioentities metadata.

```bash
# here we show tests settings
export ZK_HOST=${ZK_HOST:localhost}
export ZK_PORT=${ZK_PORT:-2181}
export SOLR_HOST=my_solr:8983
export BIOENTITIES=$DIR/fixtures/
export EXPERIMENT_FILES=$DIR/fixtures/experiment_files
export jdbc_url="jdbc:postgresql://$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"
export jdbc_username=$POSTGRES_USER
export jdbc_password=$POSTGRES_PASSWORD
export server_port=8081 #fake

export ACCESSIONS=E-MTAB-4754
export CONDA_PREFIX=/opt/conda
export output_dir=$( pwd )

./bin/create_bioentities_property_map.sh
```

this will create in this case $( pwd )/homo_sapiens.map.bin for E-MTAB-4754 which can then be used by software in the index-analytics repo. Note that multiple accessions can be given here. `create_bioentities_property_map.sh` can be used as well for a complete species (and then the Java app will traverse all experiments in the file system and create the mappings for those in that species).

## Load data - older - python based

Before loading the TSV files (e.g. `homo_sapiens.ensgene.tsv`) are converted to
JSON. The `property_weights.yaml` file contains predefined weights for an
attribute that is given priority to provide suggestions in the web app.

```bash
export BIOENTITIES_TSV=./tests/fixtures/bioentity_properties/annotations/homo_sapiens.ensgene.tsv
export PROPERTY_WEIGHTS_YAML=./property_weights.yaml

load-bioentities-collection.sh
```

This approach is not the most up to date one, and is left here should we
want to move out of the atlas-web-cli approach.

## Tests

Tests are located in the `tests` directory and use
[Bats](https://github.com/sstephenson/bats) and is probably the best way to understand how all this works. To run them, execute
`bash run-tests-in-containers.sh`. The `tests` folder includes example data in the TSV
file `fixtures/homo_sapiens.ensgene.tsv`. Alternatively, to run all tests without containers (you will need to setup all in the infrastructure - a lot of work) execute `run-tests.sh`.
