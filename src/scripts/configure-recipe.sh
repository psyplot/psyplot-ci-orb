#!/bin/bash

configure-recipe() {

    echo "${RECIPEAPPEND}" > "${RECIPEDIR}"/recipe_append.yaml

}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
    configure-recipe
fi