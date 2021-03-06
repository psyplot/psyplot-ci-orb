# Runs prior to every test
setup() {


    # install conda and build a recipe
    export CONDADIR=${BATS_TMPDIR}/miniconda-test
    source ./src/scripts/install-conda.sh
    if [ ! -d "${CONDADIR}" ]; then
        install-conda || return 1
    fi

    export DEPLOY_DIR=${BATS_TMPDIR}/docs
    export TARGET_BRANCH="test-branch"
    export DRY_RUN=1

    mkdir ${DEPLOY_DIR}
    touch ${DEPLOY_DIR}/index.html

    source ./src/scripts/deploy-docs.sh
}

@test 'deploy the docs' {

    result=$(deploy-docs | tail -n 1)
    [ "$result" == "Published" ]
}

teardown() {
    rm -rf ${BATS_TMPDIR}/docs
}
