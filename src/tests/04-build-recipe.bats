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

    git clone https://github.com/conda-forge/docrep-feedstock.git ${BATS_TMPDIR}/test-feedstock

    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    export RECIPEDIR=${BATS_TMPDIR}/test-feedstock/recipe
    export PYTHON_VERSION=3.8
    export BUILD_TOOL=conda

    source ./src/scripts/build-recipe.sh

}

@test 'build conda recipe' {

    build-recipe && \
    [ -f "${CONDADIR}/conda-bld/noarch/"docrep*.tar.bz2 ]
}

teardown() {
    rm -rf ${BATS_TMPDIR}/test-feedstock
}
