test-docs() {
    CONDADIR=$(eval echo "$CONDADIR")
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"

    conda activate docs

    WORKDIR="$(pwd)"
    cd "${SRC_DIR}" || exit 1

    sphinx-build -b linkcheck -d "${DOCTREES_DIR}" . "${WORKDIR}/${TEST_DIR}"

    cd "${WORKDIR}" || exit 1
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    test-docs
fi