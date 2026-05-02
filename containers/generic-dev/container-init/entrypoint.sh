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

USER_NAME=developer
USER_ID=${LOCAL_UID:-1000}
GROUP_ID=${LOCAL_GID:-1000}

# comprobar si ya existe un usuario con ese UID
EXISTING_USER=$(getent passwd "$USER_ID" | cut -d: -f1)

if [ -n "$EXISTING_USER" ]; then
    # Si existe, cambiar su nombre y grupo al nuevo usuario
    usermod -l "$USER_NAME" "$EXISTING_USER" 2>/dev/null || true
    groupmod -n "$USER_NAME" "$EXISTING_USER" 2>/dev/null || true
else
    # Si no existe un usuario con ese UID, crear uno nuevo
    groupadd -g "$GROUP_ID" "$USER_NAME" 2>/dev/null || true
    useradd -m -u "$USER_ID" -g "$GROUP_ID" -s /bin/bash "$USER_NAME"
fi

echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/developer

echo "Instalando..."

if /container-init/install.sh; then
    echo "Instalacion completada"
else
    debug_prompt
fi

exec gosu "$USER_NAME" "$@"