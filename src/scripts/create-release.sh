create-release() {
    [ "${TOKEN}" ] && GITHUB_TOKEN="${TOKEN}"
    cat > release_body.json << EOF
{
    "tag_name": "${NEW_TAG}",
    "name": "${NEW_TAG}: ${RELEASE_TITLE}",
    "body": "${RELEASE_MESSAGE}",
    "draft": ${DRAFT}
}
EOF
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
    create-tag
fi
