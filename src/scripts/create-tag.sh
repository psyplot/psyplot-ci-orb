
GetIncrement() {
    COMMIT_SUBJECT=$(git log -1 --pretty=%s)
    RELEASE_MESSAGE="$(git log -1 --pretty=%b)"
    SEMVER_INCREMENT=$(echo "${COMMIT_SUBJECT}" | sed -En 's/.*\[semver:(major|minor|patch|skip)\].*/\1/p')
    echo "Commit subject: ${COMMIT_SUBJECT}"
    echo "export SEMVER_INCREMENT=\"$SEMVER_INCREMENT\""  >> "$BASH_ENV"
}

CheckIncrement() {
    if [ -z "${SEMVER_INCREMENT}" ];then
        echo "Commit subject did not indicate which SemVer increment to make."
        echo "To publish orb, you can ammend the commit or push another commit with [semver:FOO] in the subject where FOO is major, minor, patch."
        echo "Note: To indicate intention to skip promotion, include [semver:skip] in the commit subject instead."
        if [ "$SHOULD_FAIL" == "1" ];then
            exit 1
        else
        echo "export PR_MESSAGE=\"BotComment: Package release was skipped due to [semver:patch|minor|major] not being included in commit message.\""  >> "$BASH_ENV"
        fi
    elif [ "$SEMVER_INCREMENT" == "skip" ];then
        echo "SEMVER in commit indicated to skip orb release"
        echo "export PR_MESSAGE=\"BotComment: Package release was skipped due to [semver:skip] in commit message.\""  >> "$BASH_ENV"
    fi
}

JoinVersion() {
  local IFS="."
  echo "$*"
}

DoIncrement() {

    LATEST_TAG="$(git describe --abbrev=0 --tags)"
    if [[ "${TAG_PREFIX}" != "" ]]; then
      LATEST_VERSION="${LATEST_TAG:${#TAG_PREFIX}}"
    else
      LATEST_VERSION="${LATEST_TAG}"
    fi
    IFS="." read -r -a VERSION_PARTS <<< "${LATEST_VERSION}"

    if [ "$SEMVER_INCREMENT" == "major" ]; then
        VERSION_PARTS[0]=$((VERSION_PARTS[0]+1))
        VERSION_PARTS[1]=0
        VERSION_PARTS[2]=0
    elif [ "$SEMVER_INCREMENT" == "minor" ]; then
        VERSION_PARTS[1]=$((VERSION_PARTS[1]+1))
        VERSION_PARTS[2]=0
    elif [ "$SEMVER_INCREMENT" == "patch" ]; then
        VERSION_PARTS[2]=$((VERSION_PARTS[2]+1))
    fi
    NEW_VERSION=$(JoinVersion "${VERSION_PARTS[@]}")
    NEW_TAG="${TAG_PREFIX}${NEW_VERSION}"

    RELEASE_TITLE="$(echo "${COMMIT_SUBJECT}" | sed 's/\s*\[semver:.*\]\s*//')"
    echo "${CLEAN_MESSAGE}"


    git tag -a "${NEW_TAG}" \
      -m "${RELEASE_TITLE}" \
      -m "${RELEASE_MESSAGE}"

    echo "export NEW_VERSION=\"${NEW_VERSION}\"" >> "$BASH_ENV"
    echo "export NEW_TAG=\"${NEW_TAG}\"" >> "$BASH_ENV"
    echo "export RELEASE_TITLE=$(printf '%q' "${RELEASE_TITLE}")" >> "$BASH_ENV"
    echo "export RELEASE_MESSAGE=$(printf '%q' "${RELEASE_MESSAGE}")" >> "$BASH_ENV"

    echo "export PR_MESSAGE=\"BotComment: *Production* version of package available for use - \\\`${NEW_TAG}\\\`\"" >> "$BASH_ENV"
}

create-tag() {
    # create a tag based on git
    GetIncrement
    CheckIncrement
    [ "$SEMVER_INCREMENT" == "skip" ] || DoIncrement
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    create-tag
fi
