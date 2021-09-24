
StopWorkflow() {
    echo "Stopping workflow."
    curl --request POST \
    --url https://circleci.com/api/v2/workflow/$CIRCLE_WORKFLOW_ID/cancel \
    --header "Circle-Token: ${CIRCLE_TOKEN}"
}

check-for-release() {
    COMMIT_SUBJECT=$(git log -1 --pretty=%s)
    RELEASE_MESSAGE="$(git log -1 --pretty=%b)"
    SEMVER_INCREMENT=$(echo "${COMMIT_SUBJECT}" | sed -En 's/.*\[semver:(major|minor|patch|skip)\].*/\1/p')


    if [ -z "${SEMVER_INCREMENT}" ]; then
        echo "No new version specified. Please indicate [semver:major/minor/patch] to create a new release"
        StopWorkflow
    elif [ "$SEMVER_INCREMENT" == "skip" ]; then
        echo "Commit marked as skip for release."
        StopWorkflow
    fi
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    check-for-release
fi
