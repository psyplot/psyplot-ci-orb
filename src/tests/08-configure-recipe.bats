# Runs prior to every test
setup() {

    export RECIPEDIR="${BATS_TMPDIR}"/test-recipe
    mkdir "${RECIPEDIR}"

    read -r -d RECIPEAPPEND << EOM
test:
  requires:
    - pyqt=5
EOM

    source ./src/scripts/configure-recipe.sh
}

@test 'configure conda recipe' {

    configure-recipe && \
    [ "$(grep pyqt=5 "${BATS_TMPDIR}"/test-recipe/recipe_append.yml)" != "" ]
}

teardown() {
    rm -rf "${BATS_TMPDIR}"/test-recipe
}
