deploy_docs() {
    # deploy docs generated with sphinx to gh-pages

    touch ${DEPLOY_DIR}/.nojekyll

    [ ! -d ${DEPLOY_DIR}/.circleci ] && mkdir -p ${DEPLOY_DIR}/.circleci
    cat ${DEPLOY_DIR}/.circleci/config.yml << EOF
version: 2.1

jobs:
  job1:
    machine: true
    steps:
      - run:
          command: echo Bye
workflows:
  version: 2.1
  dummy:
    jobs:
      - job1:
          filters:
            branches:
              ignore: gh-pages
EOF

    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"
    conda activate base

    conda install -c defaults --override-channels nodejs

    npm install -g gh-pages@3.0.0

    if [[ ${DRY_RUN} == "1" ]]; then
        ARGS="--no-push"
    fi

    gh-pages-clean

    gh-pages \
        ${ARGS} \
        --dotfiles \
        --branch ${TARGET_BRANCH} \
        --user "ci-build <ci-build@psyplot.org>" \
        --message "[skip ci] CircleCi Build ${CIRCLE_BUILD_NUM}, commit ${CIRCLE_SHA1}" \
        --dist ${DEPLOY_DIR}
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    deploy_docs
fi