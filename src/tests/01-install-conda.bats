# Runs prior to every test
setup() {
    export CONDADIR=${BATS_TMPDIR}/miniconda-test

    source ./src/scripts/install-conda.sh
}

@test 'install miniconda' {
    install-conda
    eval "$("${CONDADIR}"/bin/conda shell.bash hook)"
    [ $(which conda) == ${BATS_TMPDIR}/miniconda-test/bin/conda ]
}
