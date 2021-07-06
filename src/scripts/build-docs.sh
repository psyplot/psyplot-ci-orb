build-docs() {
    CONDADIR=$(eval echo "$CONDADIR")
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"

    if [ ${CONDAENV} != "" ]; then
        if [ -f ${CONDAENV} ]; then
            mamba env create -n docs -f ${CONDAENV}
            conda activate docs
        fi
    fi

    sphinx-build ${SRC_DIR} ${BUILD_DIR}
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    build-docs
fi