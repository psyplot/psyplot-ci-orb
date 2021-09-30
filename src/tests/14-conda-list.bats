# Runs prior to every test
setup() {

    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    source ./src/scripts/install-conda.sh
    if [ ! -d "${CONDADIR}" ]; then
        install-conda
    fi

    export CONDAENV_FILE=./src/tests/test-tests/environment.yml
    export CONDAENV_NAME="test_env"

    source ./src/scripts/setup-conda-env.sh
    setup-conda-env

    source ./src/scripts/conda-list.sh
}

@test 'conda list' {
    conda-list | grep six
}

teardown() {
    conda env remove -y -n test_env
}
