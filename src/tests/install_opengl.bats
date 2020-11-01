# Runs prior to every test
setup() {
    # Load our script file.
    source ./src/scripts/install_opengl.sh
}

@test '1: install opengl' {
    install_opengl
    case "$(uname -s)" in
        Linux*)     echo "Running test";;
        *)          skip "Not on Linux, so skipping";;
    esac
    [ "$(apt list | grep libgl1-mesa-glx)" != "" ]
}