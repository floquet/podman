#!/bin/bash
# Podman container progression script

# Step 1: Pull virgin Ubuntu image
echo "Step 1: Pulling Ubuntu 22.04 base image"
podman pull docker.io/library/ubuntu:22.04

# Step 2: Create container con-00-ubuntu-base with mappings
echo "Step 2: Creating container con-00-ubuntu-base"
podman run -it --name con-00-ubuntu-base \
  -v /etc/localtime:/etc/localtime:ro \
  -v "${lrepos}:/repos" \
  -v "${HOME}/spacklink:/spacktivity" \
  -v "${HOME}/Dropbox:/Dropbox" \
  docker.io/library/ubuntu:22.04 /bin/bash

# Step 3: Save container as image img-00-ubuntu-base
echo "Step 3: Saving image img-00-ubuntu-base"
podman commit con-00-ubuntu-base img-00-ubuntu-base

# Step 4: Create container con-01-ubuntu-deluxe from img-00-ubuntu-base
echo "Step 4: Creating container con-01-ubuntu-deluxe"
podman run -it --name con-01-ubuntu-deluxe \
  -v /etc/localtime:/etc/localtime:ro \
  -v "${lrepos}:/repos" \
  -v "${HOME}/spacklink:/spacktivity" \
  -v "${HOME}/Dropbox:/Dropbox" \
  img-00-ubuntu-base /bin/bash

# Step 5: Save container as image img-01-ubuntu-deluxe
echo "Step 5: Saving image img-01-ubuntu-deluxe"
podman commit con-01-ubuntu-deluxe img-01-ubuntu-deluxe

# Step 6: Create container con-02-spack-base from img-01-ubuntu-deluxe
echo "Step 6: Creating container con-02-spack-base"
podman run -it --name con-02-spack-base \
  -v /etc/localtime:/etc/localtime:ro \
  -v "${lrepos}:/repos" \
  -v "${HOME}/spacklink:/spacktivity" \
  -v "${HOME}/Dropbox:/Dropbox" \
  img-01-ubuntu-deluxe /bin/bash

# Step 7: Save container as image img-02-spack-base
echo "Step 7: Saving image img-02-spack-base"
podman commit con-02-spack-base img-02-spack-base

# Step 8: Create container con-03-spack-deluxe from img-02-spack-base
echo "Step 8: Creating container con-03-spack-deluxe"
podman run -it --name con-03-spack-deluxe \
  -v /etc/localtime:/etc/localtime:ro \
  -v "${lrepos}:/repos" \
  -v "${HOME}/spacklink:/spacktivity" \
  -v "${HOME}/Dropbox:/Dropbox" \
  img-02-spack-base /bin/bash

# Step 9: Save container as image img-03-spack-deluxe
echo "Step 9: Saving image img-03-spack-deluxe"
podman commit con-03-spack-deluxe img-03-spack-deluxe

# Restart commands
echo ""
echo "To restart containers:"
echo "podman start -ai con-00-ubuntu-base"
echo "podman start -ai con-01-ubuntu-deluxe"
echo "podman start -ai con-02-spack-base"
echo "podman start -ai con-03-spack-deluxe"

# Probe commands
echo ""
echo "Probe commands:"
echo "# List all containers"
podman ps -a

echo ""
echo "# List all images with sizes"
podman images

echo ""
echo "# Show disk usage"
podman system df

echo ""
echo "# Show detailed container info"
podman inspect con-00-ubuntu-base --format "{{.Name}}: {{.State.Status}}, Created: {{.Created}}"
