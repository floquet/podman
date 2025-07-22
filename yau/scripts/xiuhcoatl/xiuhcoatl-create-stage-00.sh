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

# Mon Jul 21 21:11:14 MDT 2025 ./xiuhcoatl-prep-external-storage.sh

# Step 1: Create Podman config directory (where Podman looks for storage settings)

# Step 2: Create storage directory on external drive (where IMAGES and CONTAINER data will live)

# Step 3: Set proper permissions on external storage directory

# Step 4: Create storage.conf file (tells Podman to use external drive instead of internal)

# Step 5: Verify configuration was created
# [storage]
# # CONCEPT: driver = how Podman stores IMAGES in layers (overlay is standard)
# driver = "overlay"
# # CONCEPT: runroot = temporary files for RUNNING CONTAINERS (stays on fast internal drive)
# runroot = "/run/user/1000/containers"
# # CONCEPT: graphroot = where IMAGES are stored permanently (moved to external drive)
# graphroot = "/Volumes/samsung-t7-shield-boot-ubuntu-24.02/podman-storage"

# [storage.options]
# additionalimagestores = []

# [storage.options.overlay]
# mountopt = "nodev,metacopy=on"

# Step 6: Test Podman recognizes new storage location
# store:
#   configFile: /var/home/core/.config/containers/storage.conf
#   containerStore:
#     number: 0
#     paused: 0
#     running: 0
#     stopped: 0
#   graphDriverName: overlay
#   graphOptions: {}
#   graphRoot: /var/home/core/.local/share/containers/storage
#   graphRootAllocated: 127995891712

# Total elapsed time: 00:01 (MM:SS)

