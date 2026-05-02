# FastContainer

**FastContainer** provides preconfigured containers along with a quick deployment script to spin up multiple instances of the following environments:

## Available Containers

- **`generic-dev`**  
  A general-purpose Ubuntu development container with a `developer` user. It preserves file ownership and permissions from the host workspace.

- **`qemu-arm64-dev`**  
  A QEMU-based ARM64 container that allows you to natively compile and run ARM64 applications on non-ARM hosts.

Both container types support mounting a host directory as a volume (defaults to `$CWD`).

---

## Usage

> [!IMPORTANT]
> This repository is designed to work alongside the [**project-configurator/R2eady**](https://> github.com/serg4life/R2eady) repository, which helps set up projects for various use cases.  
> A minimal standalone version of the required script is also included here.

---

## Installation

Install all containers:

    sudo make install

By default, containers are installed in `/etc/containers/`.  
You can change this path in the `Makefile`.

Install a specific container:

    sudo make install-generic-dev

---

## Deploying Containers

Using **project-configurator**:

    project-configurator docker my_container

This creates a `generic-dev` container named `my_container` in the current directory.

---

## Running a Container

    run_container my_container

This command builds and runs the container.

---

## Enabling `binfmt` on the Host

To enable multi-architecture support (required for ARM emulation):

    docker run --privileged --rm \
      -v /proc/sys/fs/binfmt_misc:/binfmt_misc \
      multiarch/qemu-user-static --reset -p yes