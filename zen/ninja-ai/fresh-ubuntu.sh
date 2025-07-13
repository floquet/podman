#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# Pull latest Ubuntu image
podman pull ubuntu:latest

# Create and run a new container with necessary mounts and privileges
podman run -it --name gcc-dev-container \
  --privileged \
  -v $(pwd):/workspace \
  ubuntu:latest /bin/bash