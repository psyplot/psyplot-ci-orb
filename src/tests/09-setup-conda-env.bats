# Runs prior to every test
setup() {

    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    source ./src/scripts/install-conda.sh
    if [ ! -d "${CONDADIR}" ]; then
        install-conda
    fi

    export PACKAGES=conda-build
    source ./src/scripts/configure-conda.sh
    configure-conda

    mkdir -p ${BATS_TMPDIR}/test-feedstock/ci

    export CONDAENV_FILE=./src/tests/test-tests/environment.yml
    export CONDAENV_NAME="test_env"

    source ./src/scripts/setup-conda-env.sh
}

@test 'setup conda env' {

    setup-conda-env && \
    [ -f "${CONDADIR}/envs/test_env/bin/python" ]
}

teardown() {
    rm -rf ${BATS_TMPDIR}/test-feedstock
    conda env remove -y -n test_env
}
