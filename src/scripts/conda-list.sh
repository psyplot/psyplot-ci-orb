#!/bin/bash

conda-list() {

    CONDADIR=$(eval echo "$CONDADIR")
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"

    conda activate "${CONDAENV_NAME}"

    conda list
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
    conda-list
fi