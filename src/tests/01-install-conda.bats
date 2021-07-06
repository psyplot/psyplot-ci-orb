# Runs prior to every test
setup() {
    export CONDADIR=${BATS_TMPDIR}/miniconda-test

    source ./src/scripts/install-conda.sh
}

@test 'install miniconda' {
    install-conda && \
    [ -f "${CONDADIR}/bin/conda" ]
}
