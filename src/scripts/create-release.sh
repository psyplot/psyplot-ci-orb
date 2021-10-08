create-release() {
    sudo apt-get update
    sudo apt-get install jq
    [ "${TOKEN}" ] && GITHUB_TOKEN="${TOKEN}"
    jq -n \
      --arg tag "${NEW_TAG}" \
      --arg name "${NEW_TAG}: ${RELEASE_TITLE}" \
      --arg body "${RELEASE_MESSAGE}" \
      "{tag_name: \$tag, name: \$name, body: \$body, draft: $DRAFT}" > release_body.json

    cat release_body.json

    curl \
        -X POST \
        -H "Authorization: Token ${GITHUB_TOKEN}" \
        -H "Content-Type: application/json" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/releases" \
        -d @release_body.json
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    create-release
fi
