# `bioentities` collection v1

Scripts to automate building and populating the `bioentities` collection.

## Requirements
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

## Load data
Before loading the TSV files (e.g. `homo_sapiens.ensgene.tsv`) are converted to
JSON. The `property_weights.yaml` file contains predefined weights for an
attribute that is given priority to provide suggestions in the web app.

```bash
export BIOENTITIES_TSV=./tests/fixtures/homo_sapiens.ensgene.tsv
export PROPERTY_WEIGHTS_YAML=./property_weights.yaml

load-bioentities-collection.sh
```

## Tests
Tests are located in the `tests` directory and use
[Bats](https://github.com/sstephenson/bats). To run them, execute
`bash tests/run-tests.sh`. The `tests` folder includes example data in the TSV
file `fixtures/homo_sapiens.ensgene.tsv`. Alternatively you can run all tests
within a Docker container by executing `run-tests-in-containers.sh`.
