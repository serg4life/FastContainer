#!/bin/bash

set -e 

debug_prompt() {
    read -p "An error occurred. Do you want to continue? (y/n) " answer
    case $answer in
        [Yy]* ) return 0;;
        [Nn]* ) echo "Exiting..."; exit 1;;
        * ) echo "Please answer y or n."; debug_prompt;;
    esac
}

on_error() {
    echo "Error occurred at line $1 while executing: $2"
    debug_prompt || exit 1
}

echo "Instalando..."

if /container-init/install.sh; then
    echo "Instalacion completada"
else
    debug_prompt
fi

exec "$@"