build-docs() {
    CONDADIR=$(eval echo "$CONDADIR")
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"

    if [ "${CONDAENV}" != "" ]; then
        if [ -f "${CONDAENV}" ]; then
            mamba env create -n docs -f "${CONDAENV}"
            conda activate docs
        fi
    fi

    WORKDIR="$(pwd)"
    cd "${SRC_DIR}" || exit 1

    sphinx-build -d "${DOCTREES_DIR}" . "${WORKDIR}/${BUILD_DIR}"

    # shellcheck disable=SC2086
    [ "${TEST_DIR}" ] && sphinx-build -b linkcheck -d "${DOCTREES_DIR}" . "${WORKDIR}/${TEST_DIR}"

    cd "${WORKDIR}" || exit 1
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    build-docs
fi