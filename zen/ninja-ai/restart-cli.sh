#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# Exit any running containers
exit

# Remove all containers
podman rm -f $(podman ps -aq)

# Remove all images
podman rmi -f $(podman images -q)

# Clean up system
podman system prune -a --volumes

# Then start from Step 2 above
