# Runs prior to every test
setup() {

    # install conda and build a recipe
    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    source ./src/scripts/install-conda.sh
    if [ ! -d "${CONDADIR}" ]; then
        install-conda || return 1
    fi

    export PACKAGES=conda-build
    source ./src/scripts/configure-conda.sh
    configure-conda  || return 1

    git clone https://github.com/conda-forge/docrep-feedstock.git "${BATS_TMPDIR}"/test-feedstock

    export RECIPEDIR="${BATS_TMPDIR}"/test-feedstock/recipe
    export PYTHON_VERSION=3.8

    source ./src/scripts/build-recipe.sh
    build-recipe || return 1

    export SRC_DIR="${BATS_TMPDIR}"/test-docs
    export BUILD_DIR="${BATS_TMPDIR}"/test-docs/_build/html
    export CONDAENV="${BATS_TMPDIR}"/test-docs/environment.yml

    source ./src/scripts/build-docs.sh
}

@test 'build the docs' {

    build-docs && \
    [ -d "${BATS_TMPDIR}"/test-docs/_build/html ] && \
    [ -f "${BATS_TMPDIR}"/test-docs/_build/html/index.html ] && \
    [ "$(conda list -n docs | grep docrep | grep local)" != "" ]
}

teardown() {
    rm -rf ${BATS_TMPDIR}/test-feedstock ${BATS_TMPDIR}/test-docs
}
