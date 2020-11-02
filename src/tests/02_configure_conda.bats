# Runs prior to every test
setup() {
    # Load our script file.
    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    source ./src/scripts/install_miniconda.sh
    if [ ! -d "${CONDADIR}" ]; then
        install_miniconda
    fi

    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    export CHANNELS="some channel"
    export MAINCHANNEL="mainchannel"
    export DEFAULTBRANCH="defaultbranch"
    export PACKAGES="conda-build"

    source ./src/scripts/configure_conda.sh
}

@test 'configure miniconda' {
    # Mock environment variables or functions by exporting them (after the script has been sourced)

    configure_conda

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
