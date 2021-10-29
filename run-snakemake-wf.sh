#!/usr/bin/env bash

PROFILE_LINE="--profile profilename"
SN_CONDA_PREFIX=${SN_CONDA_PREFIX:-$( pwd )/conda_installs}
CONDA_PREFIX_LINE="--conda-prefix $SN_CONDA_PREFIX"
USUAL_SM_ERR_OUT=${USUAL_SM_ERR_OUT:-$( pwd )/snakemake.log}
JOBS=10

snakemake --use-conda --conda-frontend mamba \
        $PROFILE_LINE \
        $CONDA_PREFIX_LINE \
        --latency-wait 10 \
        --config xxx=$xxx  \
            yyy=path/to/yyy \
        --jobs $JOBS -s Snakefile &> $USUAL_SM_ERR_OUT
