setup-conda-env() {

    CONDADIR=$(eval echo "$CONDADIR")
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"

    conda activate "${CONDAENV_NAME}" || MISSING=true

    if [ "${MISSING}"]; then

      if [[ "${CONDAENV_FILE}" != "" ]] && [[ -e "${CONDAENV_FILE}" ]]; then
        mamba env create -n "${CONDAENV_NAME}" -f "${CONDAENV_FILE}"
        if [[ "${EXTRA_PACKAGES}" != "" ]]; then
          # shellcheck disable=SC2086
          mamba install -n "${CONDAENV_NAME}" ${EXTRA_PACKAGES}
        fi
      else
          PKG=$(show-package-name "${RECIPEDIR}")
          # shellcheck disable=SC2086
          mamba create -n "${CONDAENV_NAME}" -c local "${PKG}" pytest pytest-cov python="${PYTHON_VERSION}" ${EXTRA_PACKAGES}
      fi

    fi

}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    setup-conda-env
fi