# Runs prior to every test
setup() {

    export WORKDIR="${BATS_TMPDIR}/test-repo/"
    mkdir -p "${WORKDIR}"

    export GIT_USER_NAME=test-user
    export GIT_EMAIL=test@example.com

    source ./src/scripts/configure-git.sh

    git init "${WORKDIR}"

    touch "${WORKDIR}"/dummy_file.md
    git -C "${WORKDIR}" add dummy_file.md

    git -C "${WORKDIR}" commit -m "Add dummy file"
    git -C "${WORKDIR}" tag -a v0.0.1 -m "Test commit"

    source ./src/scripts/create-tag.sh
}

@test 'Test creating a patch' {

    cd "${WORKDIR}"

    git commit --allow-empty \
      -m "[semver:patch] Test patch

This is the description"

    BASH_ENV="bash.sh" TAG_PREFIX="v" create-tag && \
    cat bash.sh && \
    source bash.sh && \
    [ "${NEW_VERSION}" == "0.0.2" ] && \
    [ "${NEW_TAG}" == "v0.0.2" ] && \
    [ "${RELEASE_TITLE}" == "Test patch" ] && \
    [ "${RELEASE_MESSAGE}" == "This is the description" ]

    git commit --allow-empty \
      -m "[semver:minor] Test minor

This is the description"

    BASH_ENV="bash.sh" TAG_PREFIX="v" create-tag && \
    cat bash.sh && \
    source bash.sh && \
    [ "${NEW_VERSION}" == "0.1.2" ] && \
    [ "${NEW_TAG}" == "v0.1.2" ] && \
    [ "${RELEASE_TITLE}" == "Test minor" ] && \
    [ "${RELEASE_MESSAGE}" == "This is the description" ]

    git commit --allow-empty \
      -m "[semver:major] Test major

This is the description"

    BASH_ENV="bash.sh" TAG_PREFIX="v" create-tag && \
    cat bash.sh && \
    source bash.sh && \
    [ "${NEW_VERSION}" == "1.1.2" ] && \
    [ "${NEW_TAG}" == "v1.1.2" ] && \
    [ "${RELEASE_TITLE}" == "Test major" ] && \
    [ "${RELEASE_MESSAGE}" == "This is the description" ]
}

teardown() {
    rm -rf "${WORKDIR}"
}
