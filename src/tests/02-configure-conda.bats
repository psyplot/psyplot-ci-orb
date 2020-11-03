# Runs prior to every test
setup() {
    # Load our script file.
    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    source ./src/scripts/install-conda.sh
    if [ ! -d "${CONDADIR}" ]; then
        install-conda
    fi

    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    export CHANNELS="some channel"
    export MAINCHANNEL="mainchannel"
    export DEFAULTBRANCH="defaultbranch"
    export PACKAGES="conda-build"

    source ./src/scripts/configure-conda.sh
}

@test 'configure miniconda' {
    # Mock environment variables or functions by exporting them (after the script has been sourced)

    configure-conda

    eval "$("${CONDADIR}"/bin/conda shell.bash hook)"
    [ "$(cat ~/.condarc | grep some)" != "" ] && \
    [ "$(cat ~/.condarc | grep channel)" != "" ] && \
    [ "$(cat ~/.condarc | grep mainchannel)" != "" ] && \
    [ "$(cat ~/.condarc | grep mainchannel/label/defaultbranch)" != "" ]
    [ "$(conda list | grep conda-build)" != "" ]
}

teardown() {
    rm ~/.condarc
}
