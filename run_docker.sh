#!/bin/bash

CONFIG_VERSION="b1.2-1"
USER=$USER
CONTAINER_DIR="."

print_help() {
    echo "Usage:    $0 <options> <container_name> <workspace_path>"
    echo "Example:  $0 -r my_container /path/to/workspace"
    echo "Options:"
    echo "          -h, --help     Show this help message"
    echo "          -r, --rebuild  Rebuild the Docker image before running"
    echo "          -v, --version  Print the version of the Docker image and container builder"
}

check_docker() {
    # Check if docker command exists
    if ! command -v docker >/dev/null 2>&1; then
        echo "❌ Docker is not installed."
        return 1
    fi

    # Check if docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        echo "❌ Docker is installed but the daemon is not running or you don't have permissions."
        return 2
    fi
    return 0
}

is_aarch64() {
    local $container_name=$1
    if [ -f ${CONTAINER_DIR}/${container_name}/aarch64 ]; then
        return 0
    else
        return 1
    fi
}

get_container_id() {
    local container_name=$1
    local container_id=${container_name}_${USER}
    if docker image ls | grep -q $container_id; then
        local id=$(docker image inspect $container_id:${CONFIG_VERSION} --format '{{ index .Config.Labels "id" }}')
    else
        return 1
    fi
    echo $id
}

get_container_version() {
    local container_name=$1
    local container_id=${container_name}_${USER}
    if docker image ls | grep -q $container_id; then
        local version=$(docker image inspect $container_id:${CONFIG_VERSION} --format '{{ index .Config.Labels "version" }}')
    else
        return 1
    fi
    echo $version
}

print_container_version() {
    local container_name=$1
    local version=$(get_container_version ${container_name})
    local id=$(get_container_id ${container_name})

    if [ -z "$version" ] || [ -z "$id" ]; then
        echo "Error: Failed to retrieve version information for container [${container_name}]"
        return 1
    fi
    echo "Container [${container_name}] version: ${id}_${version}"
    echo "Builder version: ${CONFIG_VERSION}"
}

build_image() {
    local container_name=$1
    local container_id=${container_name}_${USER}
    local container_path=${CONTAINER_DIR}/${container_name}
    echo "Building Docker image for container [${container_name}]"
    if is_aarch64 ${container_name}; then
        echo "Building aarch64 image for container [${container_name}]" 
        docker buildx build --platform=linux/arm64 -t ${container_id}:${CONFIG_VERSION} --load ${container_path} || {
            echo "Error: Failed to build Docker image for container [${container_name}]"
            exit 1
        }
    else
        docker build -t ${container_id}:${CONFIG_VERSION} ${container_path} || {
            echo "Error: Failed to build Docker image for container [${container_name}]"
            exit 1
        }
    fi
}

run_image() {
    local container_name=$1
    local container_id=${container_name}_${USER}
    local workspace_path=${2-"."}
    echo "Running Docker container [${container_name}]"
    if is_aarch64 ${container_name}; then
        echo "Running aarch64 image for container [${container_name}]" 
        docker run -v ${workspace_path}:/workspace --platform=linux/arm64 -it --rm ${container_id}:${CONFIG_VERSION} || {
            echo "Error: Failed to run Docker container [${container_name}]"
            exit 1
        }
    else
        docker run -v ${workspace_path}:/workspace -it --rm ${container_id}:${CONFIG_VERSION} || {
            echo "Error: Failed to run Docker container [${container_name}]"
            exit 1
        }
    fi
}

docker_rm() {

    local container_id=$1_${USER}
    docker image rm -f $container_id:${CONFIG_VERSION} 2>/dev/null || true
}

run_docker() {
    local container_name=$1
    local container_id=${container_name}_${USER}
    local workspace_path=${2-"."}

    if [ ! -f ./${container_name}/Dockerfile ]; then
        echo "Error: Dockerfile not found for container [${container_name}]"
        print_help
        exit 1
    fi

    if docker image ls | grep -q $container_id; then
        run_image $container_name $workspace_path
    else
        build_image $container_name && run_image $container_name $workspace_path
    fi
}

if [ $# -lt 1 ]; then
    print_help
    exit 1
fi

check_docker || exit 1

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
            exit 0
            ;;
        -v |--version)
            print_container_version $2
            shift 2
            exit 0
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