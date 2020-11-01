# Runs prior to every test
setup() {
    # Load our script file.
    source ./src/scripts/install_opengl.sh
}

@test '1: install opengl' {
    install_opengl
    [ "$(apt list | grep libgl1-mesa-glx)" != "" ]
}