#!/usr/bin/env bash
# xiuhcoatl-create-stage-00.sh
# PURPOSE: Create our first custom IMAGE by modifying Ubuntu base IMAGE
# CONCEPT: We start with Ubuntu's IMAGE (template), run it as CONTAINER (live instance),
#          modify the CONTAINER by running our script inside it, then save the 
#          modified CONTAINER back as a new IMAGE for future use

printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

counter=0; subcounter=0; start_time=${SECONDS}
function new_step() { counter=$((counter+1)); subcounter=0; echo -e "\nStep ${counter}: $1"; }
function sub_step() { subcounter=$((subcounter+1)); echo -e "\n  Substep ${counter}.${subcounter}: $1"; }
function elapsed()  { secs=$((SECONDS-start_time)); printf "\nTotal elapsed time: %02d:%02d (MM:SS)\n" $((secs/60)) $((secs%60)); }

new_step "Pull Ubuntu 22.04 base IMAGE from registry (this is downloading the template)"
# CONCEPT: An IMAGE is like a DVD - it's a read-only template we can make copies from
# CONCEPT: We're downloading Ubuntu's official IMAGE to use as our starting point
echo "podman pull ubuntu:22.04"   
      podman pull ubuntu:22.04

new_step "Verify the Ubuntu IMAGE was downloaded and stored on external drive"
# CONCEPT: This shows all IMAGES (templates) we have available to create CONTAINERS from
echo "podman images"
      podman images

new_step "Create and run a CONTAINER from the Ubuntu IMAGE"
# CONCEPT: Now we're making a CONTAINER (live, running copy) from the IMAGE (template)
# CONCEPT: --name gives our CONTAINER a specific name so we can reference it later
# CONCEPT: -it means interactive terminal - we can run commands inside the CONTAINER
# CONCEPT: The CONTAINER is now running Ubuntu, separate from your Mac
podman run --name con-stage-00-base-ubuntu -it ubuntu:22.04 /bin/bash -c "
    echo 'INSIDE CONTAINER: I am now running inside Ubuntu, not on your Mac'
    echo 'INSIDE CONTAINER: Any changes I make here will modify this CONTAINER'
    echo 'INSIDE CONTAINER: Running apt-get update to modify this CONTAINER'
    apt-get update
    echo 'INSIDE CONTAINER: CONTAINER has been modified, ready to save as new IMAGE'
    exit
"

new_step "Commit the modified CONTAINER to create a new IMAGE"
# CONCEPT: The CONTAINER now has our changes (apt-get update was run)
# CONCEPT: We're saving this modified CONTAINER as a new IMAGE template
# CONCEPT: This new IMAGE will contain Ubuntu + our modifications
echo "podman commit con-stage-00-base-ubuntu img-stage-00-base-ubuntu"
      podman commit con-stage-00-base-ubuntu img-stage-00-base-ubuntu

new_step "Verify our new custom IMAGE was created"
# CONCEPT: Now we should see both the original ubuntu:22.04 IMAGE and our new custom IMAGE
echo "podman images"
      podman images

new_step "Clean up - remove the temporary CONTAINER (we keep the IMAGE)"
# CONCEPT: We don't need the CONTAINER anymore - we saved it as an IMAGE
# CONCEPT: CONTAINERS are temporary work spaces, IMAGES are permanent templates
echo "podman rm con-stage-00-base-ubuntu"
      podman rm con-stage-00-base-ubuntu

new_step "Final verification - show what we have"
echo "CONCEPT: We started with ubuntu:22.04 IMAGE (template)"
echo "CONCEPT: We created a CONTAINER (running copy) from that IMAGE"  
echo "CONCEPT: We modified the CONTAINER by running commands inside it"
echo "CONCEPT: We saved the modified CONTAINER as img-stage-00-base-ubuntu IMAGE"
echo "CONCEPT: Now we have a new IMAGE template ready for stage-01"
echo "podman images"
      podman images

elapsed

# dantopa@Xiuhcoatl:xiuhcoatl $ ./xiuhcoatl-create-stage-00.sh
# Wed Jul 23 14:50:49 MDT 2025 ./xiuhcoatl-create-stage-00.sh

# Step 1: Pull Ubuntu 22.04 base IMAGE from registry (this is downloading the template)
# podman pull ubuntu:22.04
# Resolved "ubuntu" as an alias (/etc/containers/registries.conf.d/000-shortnames.conf)
# Trying to pull docker.io/library/ubuntu:22.04...
# Getting image source signatures
# Copying blob sha256:1d387567261efec2a352c45b8d512a8db5c246122fb9f246ae9190252a0c3adb
# Copying config sha256:1d3ca894b30cbedfe4217dc20baaa99475eac44046a1b7e5ec6addf35cb90334
# Writing manifest to image destination
# 1d3ca894b30cbedfe4217dc20baaa99475eac44046a1b7e5ec6addf35cb90334

# Step 2: Verify the Ubuntu IMAGE was downloaded and stored on external drive
# podman images
# REPOSITORY                TAG         IMAGE ID      CREATED     SIZE
# docker.io/library/ubuntu  22.04       1d3ca894b30c  9 days ago  80.4 MB

# Step 3: Create and run a CONTAINER from the Ubuntu IMAGE
# /bin/bash: error while loading shared libraries: libc.so.6: cannot change memory protections

# Step 4: Commit the modified CONTAINER to create a new IMAGE
# podman commit con-stage-00-base-ubuntu img-stage-00-base-ubuntu
# Getting image source signatures
# Copying blob sha256:3cc982388b71ef357e0157e0b7d3059dcefa4dc9fd2e3815bde6c6ce040302f3
# Copying blob sha256:dcfa7e9d73bd114cab994361aa520b3dfc142227213dfe3f34ee01002f0fbb62
# Copying config sha256:8c75713d3d5d39ee45122c9143fb4ab72f294135bb4961beec1410505d0b8b97
# Writing manifest to image destination
# 8c75713d3d5d39ee45122c9143fb4ab72f294135bb4961beec1410505d0b8b978c75713d3d5d39ee45122c9143fb4ab72f294135bb4961beec1410505d0b8b97

# Step 5: Verify our new custom IMAGE was created
# podman images
# REPOSITORY                          TAG         IMAGE ID      CREATED                 SIZE
# localhost/img-stage-00-base-ubuntu  latest      8c75713d3d5d  Less than a second ago  80.4 MB
# docker.io/library/ubuntu            22.04       1d3ca894b30c  9 days ago              80.4 MB

# Step 6: Clean up - remove the temporary CONTAINER (we keep the IMAGE)
# podman rm con-stage-00-base-ubuntu
# con-stage-00-base-ubuntu

# Step 7: Final verification - show what we have
# CONCEPT: We started with ubuntu:22.04 IMAGE (template)
# CONCEPT: We created a CONTAINER (running copy) from that IMAGE
# CONCEPT: We modified the CONTAINER by running commands inside it
# CONCEPT: We saved the modified CONTAINER as img-stage-00-base-ubuntu IMAGE
# CONCEPT: Now we have a new IMAGE template ready for stage-01
# podman images
# REPOSITORY                          TAG         IMAGE ID      CREATED                 SIZE
# localhost/img-stage-00-base-ubuntu  latest      8c75713d3d5d  Less than a second ago  80.4 MB
# docker.io/library/ubuntu            22.04       1d3ca894b30c  9 days ago              80.4 MB

# Total elapsed time: 00:05 (MM:SS)
