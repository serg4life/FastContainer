#!/bin/bash

CONFIG_VERSION="1.0-1"

print_help() {
    echo "Usage:    $0 <options> <container_name> <workspace_path>"
    echo "Example:  $0 -r my_container /path/to/workspace"
    echo "Options:"
    echo "          -h, --help     Show this help message"
    echo "          -r, --rebuild  Rebuild the Docker image before running"
}

build_image() {
    local container_name=$1
    echo "Building Docker image for container [${container_name}]"
    docker build -t ${container_name} ./${container_name}
}

run_image() {
    local container_name=$1
    local workspace_path=${2-"."}
    echo "Running Docker container [${container_name}]"
    docker run -v ${workspace_path}:/workspace -it --rm ${container_name}
}

docker_rm() {
    local container_name=$1
    docker image rm -f $container_name 2>/dev/null || true
}

run_docker() {
    local container_name=$1
    local workspace_path=${2-"."}

    if [ ! -f ./${container_name}/Dockerfile ]; then
        echo "Error: Dockerfile not found for container [${container_name}]"
        print_help
        exit 1
    fi

    if docker image ls | grep -q $container_name; then
        run_image $container_name $workspace_path
    else
        build_image $container_name && run_image $container_name $workspace_path
    fi
}

if [ $# -lt 1 ]; then
    print_help
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_help
            exit 0
            ;;

        -r|--rebuild)
            docker_rm $2
            build_image $2
            run_image $2 $3
            if [ -n $3 ]; then
                shift 3
            else
                shift 2
            fi
            ;;
        *)
            run_docker $1 $2
            if [ -n $2 ]; then
                shift 2
            else
                shift 1
            fi
            exit 0
            ;;
    esac
done