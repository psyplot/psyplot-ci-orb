# Runs prior to every test
setup() {
    # Load our script file.
    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    source ./src/scripts/install_miniconda.sh
    if [ ! -d "${CONDADIR}" ]; then
        install_miniconda
    fi
    source ./src/scripts/configure_conda.sh
    PACKAGES=conda-build configure_conda

    git clone https://github.com/conda-forge/docrep-feedstock.git ${BATS_TMPDIR}/test-feedstock

    source ./src/scripts/conda_build.sh
}

@test '1: build conda recipe' {
    # Mock environment variables or functions by exporting them (after the script has been sourced)
    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    export RECIPEDIR=${BATS_TMPDIR}/test-feedstock/recipe
    export PYTHON_VERSION=3.8
    conda_build

    case "$(uname -s)" in
        Linux*)     BUILDDIR="${CONDADIR}/conda-bld/linux-64";;
        Darwin*)    BUILDDIR="${CONDADIR}/conda-bld/osx-64";;
        *)          skip "Not on Linux or osx, so skipping";;
    esac

    [ -f "${BUILDDIR}/docrep*.tar.bz2" ]
}
