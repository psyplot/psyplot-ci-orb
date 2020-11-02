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
    conda_build

    eval "$("${CONDADIR}"/bin/conda shell.bash hook)"
    # install the local version
    pip install -e .

    export EXTRA_OPTS="-n"
    export LABEL="ci-test"

    source ./src/scripts/deploy_pkg.sh
}

@test 'deploy conda recipe' {

    [ $(deploy_pkg | tail -n 1) == "Success!" ]
}

teardown() {
    rm -rf ${BATS_TMPDIR}/test-feedstock
}
