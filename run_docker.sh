#!/bin/bash

CONTAINER_NAME=$1

print_help() {
    echo "Usage:    $0 <container_name>"
    echo "Example:  $0 my_container"
}

build_image() {
    local container_name=$1
    echo "Building Docker image for container '${container_name}'"
    docker build -t ${container_name} ./${container_name}
}

run_image() {
    local container_name=$1
    echo "Running Docker container '${container_name}'"
    docker run -v ./${container_name}/workspace:/workspace -it --rm ${container_name}
}

run_docker() {
    local container_name=$1

     if docker image ls | grep -q $container_name; then
        run_image $container_name
    else
        build_image $container_name && run_image $container_name
    fi
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