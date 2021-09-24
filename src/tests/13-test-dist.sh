# Runs prior to every test
setup() {

    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    source ./src/scripts/install-conda.sh
    if [ ! -d "${CONDADIR}" ]; then
        install-conda
    fi

    source ./src/scripts/test-dist.sh
}

@test 'Build and test the dist' {

    test-dist && \
    [ -f "dist/"*.tar.gz ]
}

teardown() {
    rm -rf dist/
}
