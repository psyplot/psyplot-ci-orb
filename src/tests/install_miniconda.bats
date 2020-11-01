# Runs prior to every test
setup() {
    # Load our script file.
    source ./src/scripts/install_conda.sh
}

@test '1: install miniconda' {
    # Mock environment variables or functions by exporting them (after the script has been sourced)
    export INSTALL_TO=~/miniconda3

    install_miniconda
    [ $(which conda) == $HOME/miniconda3/envs/work/bin/conda ]
}