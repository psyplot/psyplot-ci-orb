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
    build-recipe

    eval "$("${CONDADIR}"/bin/conda shell.bash hook)"
    # install the local version
    pip install --no-deps .

    export EXTRA_OPTS="-n -u psyplot"
    export LABEL="ci-test"

    source ./src/scripts/deploy-pkg.sh
}

@test 'deploy conda recipe' {

    [ $(deploy-pkg | tail -n 1) == "Success!" ]
}

teardown() {
    rm -rf ${BATS_TMPDIR}/test-feedstock
}
