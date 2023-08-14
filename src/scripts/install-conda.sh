#!/bin/bash

install-conda() {
    CONDADIR=$(eval echo "$CONDADIR")
    echo ""
    echo "Installing a fresh version of Mambaforge."
    MINICONDA_URL="https://github.com/conda-forge/miniforge/releases/latest/download/"

    case "$(uname -s)" in
        Linux*)     machine=Linux;;
        Darwin*)    machine=MacOSX;;
        *)          >&2 echo "unsupported machine!" && return 1;;
    esac

    echo "Operating system: ${machine}"

    MINICONDA_FILE="Mambaforge-${machine}-x86_64.sh"
    curl -L -O "${MINICONDA_URL}/${MINICONDA_FILE}"
    bash "$MINICONDA_FILE" -bp "${CONDADIR}"
    rm "${MINICONDA_FILE}"

    # add conda init
    eval "$("${CONDADIR}"/bin/conda shell.bash hook)"
    conda init
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
    install-conda
fi
