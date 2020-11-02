install_miniconda() {
    echo ""
    echo "Installing a fresh version of Miniconda."
    MINICONDA_URL="https://repo.anaconda.com/miniconda"

    case "$(uname -s)" in
        Linux*)     machine=Linux;;
        Darwin*)    machine=MacOSX;;
        *)          >&2 echo "unsupported machine!" && return 1;;
    esac

    echo "Operating system: ${machine}"

    MINICONDA_FILE="Miniconda3-latest-${machine}-x86_64.sh"
    curl -L -O "${MINICONDA_URL}/${MINICONDA_FILE}"
    bash "$MINICONDA_FILE" -bp "${CONDADIR}"
    rm "${MINICONDA_FILE}"

    # add conda init
    eval "$("${CONDADIR}"/bin/conda shell.bash hook)"
    conda init
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    install_miniconda
fi
