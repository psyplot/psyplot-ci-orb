run-parallel-tests() {

    CONDADIR=$(eval echo "$CONDADIR")
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"

    conda activate "${CONDAENV_NAME}"
    TESTS="$(circleci tests glob "${TESTDIR}/test_*.py" "${TESTDIR}/*/test_*.py" | circleci tests split --split-by=timings)"
    echo "Test files:"
    echo "${TESTS}"
    mkdir -p "${TESTUPLOADDIR}"
    pytest -h || pip install pytest pytest-cov
    pytest -xv --junitxml="${TESTUPLOADDIR}"/junit.xml ${PYTEST_ARGS} ${TESTS}
    conda deactivate

}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    run-parallel-tests
fi