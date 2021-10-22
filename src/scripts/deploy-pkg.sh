deploy-pkg() {
    # deploy to package to the anaconda channel
    CONDADIR=$(eval echo "$CONDADIR")
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"

    conda activate base

    if [ "${ORB_VERSION}" != "" ]; then
        VERSION="===${ORB_VERSION}"
    fi

    # shellcheck disable=SC2143
    if [ ! "$(pip freeze | grep -q psyplot-ci-orb)" ]; then
        echo "Installing psyplot-ci-orb${VERSION}"
        conda install anaconda-client conda-build
        pip install -i https://pypi.anaconda.org/psyplot/simple --no-deps psyplot-ci-orb"${VERSION}"
    fi

    if [ "${LABEL}" != "" ]; then
        ARGS="--label ${LABEL}"
    fi

    if [ "${USE_BRANCH}" == "1" ] && [ "${CIRCLE_TAG}" == "" ] && [ "${CIRCLE_BRANCH}" != "" ]; then
        ARGS="${ARGS} --label ${CIRCLE_BRANCH/\//-}"
    fi

    if [ "${TOKEN}" != "" ]; then
        ARGS="${ARGS} --token ${TOKEN}"
    fi

    # shellcheck disable=SC2086
    deploy-conda-recipe "${RECIPEDIR}" ${ARGS} ${EXTRA_OPTS}
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    deploy-pkg
fi
