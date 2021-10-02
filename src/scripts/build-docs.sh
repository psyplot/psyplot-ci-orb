build-docs() {
    CONDADIR=$(eval echo "$CONDADIR")
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"

    conda activate ${CONDAENV_NAME}

    WORKDIR="$(pwd)"
    cd "${SRC_DIR}" || exit 1

    # shellcheck disable=SC2086
    for BUILDER in ${BUILDERS}; do
        sphinx-build -b "${BUILDER}" -d "${WORKDIR}/${BUILD_DIR}/doctrees" . "${WORKDIR}/${BUILD_DIR}/${BUILDER}"
    done

    cd "${WORKDIR}" || exit 1
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    build-docs
fi