setup-conda-env() {

    CONDADIR=$(eval echo "$CONDADIR")
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"

    if [[ "${CONDAENV_FILE}" != "" ]] && [[ -e "${CONDAENV_FILE}" ]]; then
      mamba env create -n "${CONDAENV_NAME}" -f "${CONDAENV_FILE}"
    else
        PKG=$(show-package-name "${RECIPEDIR}")
        mamba create -n "${CONDAENV_NAME}" -c local ${PKG} pytest pytest-cov
    fi

}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    setup-conda-env
fi