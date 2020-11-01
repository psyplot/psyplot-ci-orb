install_opengl() {
    case "$(uname -s)" in
        Linux*)     machine=Linux;;
        *)    echo "Not on Linux, so skipping" && return 0;;
    esac
    echo "Installing libgl1-mesa-glx and libegl1-mesa-dev"

    sudo apt-get update
    sudo apt-get install libgl1-mesa-glx libegl1-mesa-dev
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    install_opengl
fi
