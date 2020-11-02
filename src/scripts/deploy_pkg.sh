deploy_pkg() {
    # deploy to package to the anaconda channel
    CONDADIR=$(eval echo "$CONDADIR")
    which conda || eval "$("${CONDADIR}"/bin/conda shell.bash hook)"

    conda activate base

    pip install -i https://pypi.anaconda.org/psyplot/simple psyplot-ci-orb
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    deploy_pkg
fi