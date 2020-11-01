# Runs prior to every test
setup() {
    # Load our script file.
    source ./src/scripts/install_miniconda.sh
}

@test '1: install miniconda' {
    # Mock environment variables or functions by exporting them (after the script has been sourced)
    export CONDADIR=${BATS_TMPDIR}/miniconda-test

    install_miniconda
    eval "$("${CONDADIR}"/bin/conda shell.bash hook)"
    [ $(which conda) == ${BATS_TMPDIR}/miniconda-test/bin/conda ]
}