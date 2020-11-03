# Runs prior to every test
setup() {
    # Load our script file.
    source ./src/scripts/install-opengl.sh
}

@test 'install opengl' {
    install-opengl
    case "$(uname -s)" in
        Linux*)     echo "Running test";;
        *)          skip "Not on Linux, so skipping";;
    esac
    [ "$(apt list | grep libgl1-mesa-glx)" != "" ]
}
