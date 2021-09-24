# trigger the release workflow
#
# This command has been largely taken from the official orb-tools-orb at
# https://github.com/CircleCI-Public/orb-tools-orb/releases/tag/v10.0.5

Setup() {
    VCS_TYPE=$(echo "${CIRCLE_BUILD_URL}" | cut -d '/' -f 4)
    T=$(eval echo "$TOKEN")
}

BuildParams() {
    PARAM_MAP=$(eval echo "${PARAM_MAP}")
    # shellcheck disable=SC2016
    REQUEST_PARAMS='{\"branch\": \"$CIRCLE_BRANCH\", \"parameters\": $PARAM_MAP}'
    eval echo "${REQUEST_PARAMS}" > pipelineparams.json
}

DoCurl() {
    curl -u "${T}": -X POST --header "Content-Type: application/json" -d @pipelineparams.json \
      "https://circleci.com/api/v2/project/${VCS_TYPE}/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/pipeline" -o /tmp/curl-result.txt
}

Result() {
    # shellcheck disable=SC2002
    CURL_RESULT=$(cat /tmp/curl-result.txt)
    if [[ $(echo "$CURL_RESULT" | jq -r .message) == "Not Found" || $(echo "$CURL_RESULT" | jq -r .message) == "Permission denied" || $(echo "$CURL_RESULT" | jq -r .message) == "Project not found" ]]; then
        echo "Was unable to trigger integration test workflow. API response:"
        cat /tmp/curl-result.txt | jq -r .message
        exit 1
    else
        echo "Pipeline triggered!"
        echo "https://app.circleci.com/jobs/${VCS_TYPE}/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/$(cat /tmp/curl-result.txt | jq -r .number)"
    fi
}

TriggerRelease() {
    Setup
    BuildParams
    DoCurl
    Result
}

Main() {
    COMMIT_SUBJECT=$(git log -1 --pretty=%s)
    SEMVER_INCREMENT=$(echo "${COMMIT_SUBJECT}" | sed -En 's/.*\[semver:(major|minor|patch|skip)\].*/\1/p')

    if [ -z "${SEMVER_INCREMENT}" ]; then
        echo "No new version specified. Please indicate [semver:major/minor/patch] to create a new release"
    elif [ "$SEMVER_INCREMENT" == "skip" ]; then
        echo "Commit marked as skip for release."
    else
        echo "Semver release indicated. Trigger release workflow now."
        TriggerRelease
    fi
}


# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    Main
fi
