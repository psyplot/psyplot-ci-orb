configure-conda() {
    CONDADIR=$(eval echo "$CONDADIR")
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"

    conda config --set always_yes yes --set changeps1 no
    conda config --add channels conda-forge
    for CHN in ${CHANNELS}; do
        conda config --add channels "${CHN}"
    done
    if [[ "${MAINCHANNEL}" != "" ]]; then
        conda config --add channels "${MAINCHANNEL}"
        if [[ "${DEFAULTBRANCH}" != "" ]]; then
            conda config --add channels "${MAINCHANNEL}"/label/"${DEFAULTBRANCH}"
        fi
        if [ "${USE_BRANCH}" == "1" ] && [ "${CIRCLE_TAG}" == "" ] && [ "${CIRCLE_BRANCH}" != "" ]; then
            conda config --add channels "${MAINCHANNEL}"/label/"${CIRCLE_BRANCH}"
        fi
    fi

    conda install -c defaults --override-channels ${PACKAGES}
    conda install -c conda-forge -n base mamba
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    configure-conda
fi