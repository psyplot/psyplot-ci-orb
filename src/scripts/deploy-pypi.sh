#!/bin/bash

test-dist() {
    CONDADIR=$(eval echo "$CONDADIR")
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"

    COMMIT_SUBJECT=$(git log -1 --pretty=%s)
    # shellcheck disable=SC2001
    RELEASE_TITLE="$(echo "${COMMIT_SUBJECT}" | sed 's/\s*\[semver:.*\]\s*//')"

    which twine || pip install twine

    if [ -d dist ]; then
        rm -r dist
    fi

    python setup.py sdist
    twine check dist/*.tar.gz

    [ "${PYPI_USER}" ] && export TWINE_USERNAME="${PYPI_USER}"
    [ "${PYPI_PASSWORD}" ] && export TWINE_PASSWORD="${PYPI_PASSWORD}"


    if [ "${DRYRUN}" ]; then
        echo "twine upload --non-interactive -c \"${RELEASE_TITLE}\"" dist/*.tar.gz
    else
        twine upload --non-interactive -c "${RELEASE_TITLE}" dist/*.tar.gz
    fi
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
    test-dist
fi