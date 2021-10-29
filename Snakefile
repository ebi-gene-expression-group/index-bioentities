

rule all:
    input:
        required_outputs=


rule remove_old_annotations:
    """
    Remove old annotations from Solr for a species
    """
    log:
    input:
    output:
    shell:
    """
    """

rule prep_working_dirs:
    """
    Prepare app and working directories
    """
    conda: "envs/cli.yaml"
    log:
    input:
    output:
    shell:
    """
    ./gradlew :cli:bootJar
    mkdir ./bioentities ./bulk-analytics
    """


rule create_json_files:
    """
    Generate bioentity JSONL files for a species
    """
    conda: "envs/cli.yaml"
    log:
    input:
    output:
    shell:
    """
    java -jar ./cli/build/libs/atlas-cli-bulk.jar \
    bioentities-json -o ./bioentities
    """


rule index_load_annotations:
    """
    Index annotations
    """
    conda: "envs/cli.yaml"
    log:
    input:
    output:
    shell:
    """
    for FILE in ./bioentities/mus_musculus.*
    do
        INPUT_JSONL=$FILE SOLR_COLLECTION=bioentities SCHEMA_VERSION=1 ./bin/solr-jsonl-chunk-loader.sh
    done
    """