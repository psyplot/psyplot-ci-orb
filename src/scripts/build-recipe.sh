#!/bin/bash

build-recipe() {
    CONDADIR=$(eval echo "$CONDADIR")
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"

    # shellcheck disable=SC2086
    ${BUILD_TOOL} build "${RECIPEDIR}" --python "${PYTHON_VERSION}" ${EXTRA_ARGS}
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
    build-recipe
fi