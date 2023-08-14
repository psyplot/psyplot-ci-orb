# Runs prior to every test
setup() {

    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    if [ ! -d "${CONDADIR}" ]; then
        source ./src/scripts/install-conda.sh
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
    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"
    conda env remove -y -n test_env
}
