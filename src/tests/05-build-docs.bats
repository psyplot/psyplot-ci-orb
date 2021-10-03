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

    export CONDAENV_FILE=./src/tests/test-docs/environment.yml
    export CONDAENV_NAME="test_docs_env"

    source ./src/scripts/setup-conda-env.sh
    setup-conda-env || return 1

    export SRC_DIR=./src/tests/test-docs
    export BUILD_DIR=./src/tests/test-docs/_build
    export BUILDERS="linkcheck html"

    source ./src/scripts/build-docs.sh
}

@test 'build the docs' {

    build-docs && \
    [ -d ./src/tests/test-docs/_build/html ] && \
    [ -f ./src/tests/test-docs/_build/html/index.html ] &&
    [ -f ./src/tests/test-docs/_build/linkcheck/output.txt ]
}

teardown() {
    conda env remove -y -n test_docs_env
    rm -rf ./src/tests/test-docs/_build
}
