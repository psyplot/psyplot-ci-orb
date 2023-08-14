#!/bin/bash

run-parallel-tests() {

    CONDADIR=$(eval echo "$CONDADIR")
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"

    conda activate "${CONDAENV_NAME}"

    WORKDIR="$(pwd)"

    cd "${TESTDIR}" || exit 1
    TESTS="$(circleci tests glob "test_*.py" "*/test_*.py" | circleci tests split --split-by=timings)"
    echo "Test files:"
    echo "${TESTS}"
    mkdir -p "${TESTUPLOADDIR}"
    pytest -h || pip install pytest pytest-cov

    if [ "${BUILDREFS}" ]; then
        # shellcheck disable=SC2086
        pytest -xv --ref --junitxml="${TESTUPLOADDIR}"/junit.xml ${PYTEST_ARGS} ${TESTS}
    fi

    # shellcheck disable=SC2086
    pytest -xv --cov-append --junitxml="${TESTUPLOADDIR}"/junit.xml ${PYTEST_ARGS} ${TESTS}

    cd "${WORKDIR}" || exit 1

    conda deactivate

}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
    run-parallel-tests
fi