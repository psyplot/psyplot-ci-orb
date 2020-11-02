# Runs prior to every test
setup() {

    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    source ./src/scripts/install_miniconda.sh
    if [ ! -d "${CONDADIR}" ]; then
        install_miniconda
    fi

    export PACKAGES=conda-build
    source ./src/scripts/configure_conda.sh
    configure_conda

    git clone https://github.com/conda-forge/docrep-feedstock.git ${BATS_TMPDIR}/test-feedstock

    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    export RECIPEDIR=${BATS_TMPDIR}/test-feedstock/recipe
    export PYTHON_VERSION=3.8

    source ./src/scripts/conda_build.sh
}

@test 'build conda recipe' {

    conda_build && \
    [ -f "${CONDADIR}/conda-bld/noarch/"docrep*.tar.bz2 ]
}

teardown() {
    rm -rf ${BATS_TMPDIR}/test-feedstock
}
