# Runs prior to every test
setup() {

    mkdir "${BATS_TMPDIR}"/docs
    cat > "${BATS_TMPDIR}"/docs/environment.yml << EOF
name: docs
channels:
    - local
dependencies:
    - python=3.8
    - docrep
    - sphinx
EOF
    echo 'project = "test"' > "${BATS_TMPDIR}"/docs/conf.py

    cat > "${BATS_TMPDIR}"/docs/index.rst << EOF
This is just a test to build the docs
=====================================

.. toctree::
   :hidden:
EOF

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

    export SRC_DIR="${BATS_TMPDIR}"/docs
    export BUILD_DIR="${BATS_TMPDIR}"/docs/_build/html
    export CONDAENV="${BATS_TMPDIR}"/docs/environment.yml

    source ./src/scripts/build-docs.sh
}

@test 'build the docs' {

    build-docs && \
    [ -d "${BATS_TMPDIR}"/docs/_build/html ] && \
    [ -f "${BATS_TMPDIR}"/docs/_build/html/index.html ] && \
    [ "$(conda list -n docs | grep docrep | grep local)" != "" ]
}

teardown() {
    rm -rf ${BATS_TMPDIR}/test-feedstock ${BATS_TMPDIR}/docs
}
