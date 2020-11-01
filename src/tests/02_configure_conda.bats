# Runs prior to every test
setup() {
    # Load our script file.
    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    source ./src/scripts/install_miniconda.sh
    if [ ! -d "${CONDADIR}" ]; then
        install_miniconda
    fi
    source ./src/scripts/configure_conda.sh
}

@test '1: install miniconda' {
    # Mock environment variables or functions by exporting them (after the script has been sourced)
    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    export CHANNELS="some channel"
    export MAINCHANNEL=mainchannel
    export DEFAULTBRANCH=defaultbranch
    configure_conda

    eval "$("${CONDADIR}"/bin/conda shell.bash hook)"
    [ "$(cat ~/.condarc | grep "- some")" != "" ] && \
    [ "$(cat ~/.condarc | grep "- channel")" != "" ] && \
    [ "$(cat ~/.condarc | grep "- mainchannel")" != "" ] && \
    [ "$(cat ~/.condarc | grep "- mainchannel/label/defaultbranch")" != "" ]
}