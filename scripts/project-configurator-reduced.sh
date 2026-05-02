#!/bin/bash

CWD=$(pwd)
BARE_REPO=false
CONFIG_DIR="/etc/project-configurator"

# Default container configuration name
CONTAINERS_DIR="/etc/containers"
CONTAINER_NAME="generic-dev"
CONTAINER=${CONTAINERS_DIR}/${CONTAINER_NAME}

ask_confirmation() {
    read -p "$1 (y/n) " answer
    case $answer in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        * ) echo "Please answer y or n."; ask_confirmation "$1";;
    esac
}

print_help() {
    echo ""
    echo "Usage:            $0 <options> <configuration>"
    echo "Options:"
    echo "                  --help, -h                  Displays this help message."
    echo ""
    echo "Configurations:"
    echo "                  docker <container_name>     Initializes a repository with a Docker container."
    echo ""
}

bare_init() {
    if [ ! -f README.md ]; then
        touch README.md
    fi

    if [ ! -f .gitignore ]; then
        bash -c "cat <<'EOL' > .gitignore
node_modules/
.env
dist/
build/
__pycache__/
.DS_Store
EOL"
    fi

    if [ ! -d .git ]; then
        git init
        git add -A
        git commit -m "Initial commit"
        git checkout -b develop
    else
        echo "> GIT repository already exists. Skipping GIT initialization."
    fi
    echo ""
    echo "> Repository initialized successfully."
    echo ""
}

init() {
    mkdir -p src tests docs lib
    bare_init
}

init_git() {
    if [ ${BARE_REPO} = false ]; then
        init
    else
        bare_init
    fi
}

init_docker() {
    local container_name="${1:-dev-container}"
    if [ -d "${container_name}" ]; then
        ask_confirmation "A ${container_name} directory already exists. Do you want to overwrite its contents?"
        if [ $? -eq 0 ]; then
            rm -rf ${container_name}/
            cp -r ${CONTAINER} ${container_name}
            install -m 755 ${CONTAINERS_DIR}/starter ./
        else
            echo "Skipping Docker configuration."
        fi
    else
        cp -r ${CONTAINER} ${container_name}
        install -m 755 ${CONTAINERS_DIR}/starter ./
    fi
    echo "> To deploy the container use the following command:"
    echo ""
    ./starter -h

    init_git
}

init_aitools() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local aitools_source="${CONFIG_DIR}/ai-toolset/GENERAL"
    local aitools_dest=".github"

    # Check if ai-toolset source exists
    if [ ! -d "${aitools_source}" ]; then
        echo "Error: AI toolset source not found at ${aitools_source}"
        echo "Please ensure project-configurator is installed correctly."
        return 1
    fi

    # Create .github directory if it doesn't exist
    mkdir -p "${aitools_dest}"

    echo "Installing AI Toolset..."
    echo ""

    # Copy README.md for documentation
    if [ -f "${aitools_source}/../README.md" ]; then
        cp "${aitools_source}/../README.md" "${aitools_dest}/AI-TOOLSET-README.md"
        echo "✓ README.md copied for documentation"
    fi

    # Copy coordination model for documentation
    if [ -f "${aitools_source}/AGENT-COORDINATION.md" ]; then
        cp "${aitools_source}/AGENT-COORDINATION.md" "${aitools_dest}/AGENT-COORDINATION.md"
        echo "✓ Coordination model copied for documentation"
    fi

    # Copy agents
    if [ -d "${aitools_source}/agents" ]; then
        mkdir -p "${aitools_dest}/agents"
        cp -r "${aitools_source}/agents/"* "${aitools_dest}/agents/" 2>/dev/null || true
        echo "✓ Agents installed"
    fi

    # Copy skills
    if [ -d "${aitools_source}/skills" ]; then
        mkdir -p "${aitools_dest}/skills"
        cp -r "${aitools_source}/skills/"* "${aitools_dest}/skills/" 2>/dev/null || true
        echo "✓ Skills installed"
    fi

    # Copy prompts
    if [ -d "${aitools_source}/prompts" ]; then
        mkdir -p "${aitools_dest}/prompts"
        cp -r "${aitools_source}/prompts/"* "${aitools_dest}/prompts/" 2>/dev/null || true
        echo "✓ Prompts installed"
    fi

    # Copy instructions
    if [ -d "${aitools_source}/instructions" ]; then
        mkdir -p "${aitools_dest}/instructions"
        cp -r "${aitools_source}/instructions/"* "${aitools_dest}/instructions/" 2>/dev/null || true
        echo "✓ Instructions installed"
    fi

    # Copy hooks
    if [ -d "${aitools_source}/hooks" ]; then
        mkdir -p "${aitools_dest}/hooks"
        cp -r "${aitools_source}/hooks/"* "${aitools_dest}/hooks/" 2>/dev/null || true
        cp "${aitools_source}/hooks/hooks.json" "${aitools_dest}/hooks/"
        # Make hook scripts executable
        find "${aitools_dest}/hooks" -name "*.sh" -exec chmod +x {} \;
        echo "✓ Hooks installed"
    fi

    # Copy templates if they exist
    if [ -d "${aitools_source}/templates" ]; then
        mkdir -p "${aitools_dest}/templates"
        cp -r "${aitools_source}/templates/"* "${aitools_dest}/templates/" 2>/dev/null || true
        echo "✓ Templates installed"
    fi

    # Create logs directory
    mkdir -p logs/copilot
    mkdir -p logs/copilot/governance
    echo "✓ Log directory created"

    echo ""
    echo "✅ AI Toolset installation complete!"
    echo ""
}

cd ${CWD}

if [ $# -eq 0 ]; then
    init
    exit 0
fi

if [ $# -eq 1 ]; then
    if [ "$1" == "--bare" ] || [ "$1" == "-b" ]; then
        BARE_REPO=true 
        bare_init
        exit 0
    fi
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        docker)
            init_docker $2
            if [ -n "$2" ]; then
                shift 2
            else
                shift
            fi
            ;;
        *)
            print_help
            exit 1
            ;;
    esac
done
