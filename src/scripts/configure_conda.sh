configure_conda() {
    which conda || source "${CONDADIR}"/bin/activate base
    conda config --set always_yes yes --set changeps1 no
    conda update -q conda
    for CHANNEL in ${CHANNELS}; do
        conda config --add channels "${CHANNEL}"
    done
    if [[ "${MAINCHANNEL}" != "" ]]; then
        conda config --add channels "${MAINCHANNEL}"
        if [[ "${DEFAULTBRANCH}" != "" ]]; then
            conda config --add channels "${MAINCHANNEL}"/label/"${DEFAULTBRANCH}"
        fi
    fi
    if [[ "${CIRCLE_TAG}" == "" ]]; then
        conda config --add channels psyplot/label/"${CIRCLE_BRANCH}"
    fi
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    configure_conda
fi