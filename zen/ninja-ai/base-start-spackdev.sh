#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

echo "podman run -it --name gcc-dev-container -v /Users/dantopa/GitHub/podman:/workspace ubuntu:latest /bin/bash"

# Create and run a new container with necessary mounts and privileges
podman run -it --name gcc-dev-container \
  -v /Users/dantopa/GitHub/podman:/workspace \
  ubuntu:latest /bin/bash

