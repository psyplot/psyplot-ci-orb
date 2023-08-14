# Runs prior to every test
setup() {
    # Load our script file.
    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    source ./src/scripts/install-conda.sh
    if [ ! -d "${CONDADIR}" ]; then
        install-conda
    fi

    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    export CHANNELS="conda-forge"
    export MAINCHANNEL="psyplot"
    export DEFAULTBRANCH="master"
    export PACKAGES="conda-build"

    source ./src/scripts/configure-conda.sh
}

@test 'configure miniconda' {
    # Mock environment variables or functions by exporting them (after the script has been sourced)

    configure-conda

    eval "$("${CONDADIR}"/bin/conda shell.bash hook)"
    [ "$(cat ~/.condarc | grep conda-forge)" != "" ] && \
    [ "$(cat ~/.condarc | grep psyplot)" != "" ] && \
    [ "$(cat ~/.condarc | grep psyplot/label/master)" != "" ]
    [ "$(conda list | grep conda-build)" != "" ]
}

teardown() {
    rm -rf ~/.condarc
}
