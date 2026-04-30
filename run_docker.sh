#!/bin/bash

CONTAINER_NAME=$1

print_help() {
    echo "Usage:    $0 <container_name>"
    echo "Example:  $0 my_container"
}

run_docker() {
    local container_name=$1
    docker build -t ${container_name} ./${container_name} && docker run -v ./${container_name}/workspace:/workspace -it --rm ${container_name}
}

if [ $# -ne 1 ]; then
    print_help
    exit 1
fi

if [ -f ./${CONTAINER_NAME}/Dockerfile ]; then
    run_docker ${CONTAINER_NAME}
else
    echo "Error: Dockerfile not found for container '${CONTAINER_NAME}'"
    exit 1
fi