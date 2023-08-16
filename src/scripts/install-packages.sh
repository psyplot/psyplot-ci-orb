#!/bin/bash

install-packages() {

    CONDADIR=$(eval echo "$CONDADIR")
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"
    # shellcheck disable=SC2086
    mamba install -n  "${CONDAENV_NAME}" ${EXTRA_PACKAGES}

}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
    install-packages
fi