#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# xiuhcoatl-prep-external-storage.sh
# PURPOSE: Configure Podman to use external Samsung T7 drive instead of internal drive
# CONCEPT: Podman stores IMAGES (templates) and CONTAINER data on disk
#          We're moving this storage location to prevent filling up internal drive

counter=0; subcounter=0; start_time=${SECONDS}
function new_step() { counter=$((counter+1)); subcounter=0; echo -e "\nStep ${counter}: $1"; }
function sub_step() { subcounter=$((subcounter+1)); echo -e "\n  Substep ${counter}.${subcounter}: $1"; }
function elapsed()  { secs=$((SECONDS-start_time)); printf "\nTotal elapsed time: %02d:%02d (MM:SS)\n" $((secs/60)) $((secs%60)); }

# CONCEPT: Before we can CREATE images or RUN containers, we must tell Podman where to store them
new_step "Create Podman config directory (where Podman looks for storage settings)"
mkdir -p ~/.config/containers

new_step "Create storage directory on external drive (where IMAGES and CONTAINER data will live)"
mkdir -p "/Volumes/samsung-t7-shield-boot-ubuntu-24.02/podman-storage"

new_step "Set proper permissions on external storage directory"
chmod 755 "/Volumes/samsung-t7-shield-boot-ubuntu-24.02/podman-storage"

new_step "Create storage.conf file (tells Podman to use external drive instead of internal)"
cat > ~/.config/containers/storage.conf << 'EOF'
[storage]
# CONCEPT: driver = how Podman stores IMAGES in layers (overlay is standard)
driver = "overlay"
# CONCEPT: runroot = temporary files for RUNNING CONTAINERS (stays on fast internal drive)
runroot = "/run/user/1000/containers"
# CONCEPT: graphroot = where IMAGES are stored permanently (moved to external drive)
graphroot = "/Volumes/samsung-t7-shield-boot-ubuntu-24.02/podman-storage"

[storage.options]
additionalimagestores = []

[storage.options.overlay]
mountopt = "nodev,metacopy=on"
EOF

new_step "Verify configuration was created"
cat ~/.config/containers/storage.conf

new_step "Test Podman recognizes new storage location"
# CONCEPT: This shows where Podman will store IMAGES and CONTAINER data
podman info | grep -A 10 "store"

elapsed

# dantopa@Xiuhcoatl:xiuhcoatl $ ./xiuhcoatl-create-stage-00.sh 
# Mon Jul 21 21:15:26 MDT 2025 ./xiuhcoatl-create-stage-00.sh

# Step 1: Pull Ubuntu 22.04 base IMAGE from registry (this is downloading the template)
# Resolved "ubuntu" as an alias (/etc/containers/registries.conf.d/000-shortnames.conf)
# Trying to pull docker.io/library/ubuntu:22.04...
# Getting image source signatures
# Copying blob sha256:1d387567261efec2a352c45b8d512a8db5c246122fb9f246ae9190252a0c3adb
# Copying config sha256:1d3ca894b30cbedfe4217dc20baaa99475eac44046a1b7e5ec6addf35cb90334
# Writing manifest to image destination
# 1d3ca894b30cbedfe4217dc20baaa99475eac44046a1b7e5ec6addf35cb90334

# Step 2: Verify the Ubuntu IMAGE was downloaded and stored on external drive
# REPOSITORY                TAG         IMAGE ID      CREATED     SIZE
# docker.io/library/ubuntu  22.04       1d3ca894b30c  7 days ago  80.4 MB

# Step 3: Create and run a CONTAINER from the Ubuntu IMAGE
# INSIDE CONTAINER: I am now running inside Ubuntu, not on your Mac
# INSIDE CONTAINER: Any changes I make here will modify this CONTAINER
# INSIDE CONTAINER: Running apt-get update to modify this CONTAINER
# Get:1 http://archive.ubuntu.com/ubuntu jammy InRelease [270 kB]
# Get:2 http://security.ubuntu.com/ubuntu jammy-security InRelease [129 kB]
# Get:3 http://archive.ubuntu.com/ubuntu jammy-updates InRelease [128 kB]
# Get:4 http://archive.ubuntu.com/ubuntu jammy-backports InRelease [127 kB]
# Get:5 http://archive.ubuntu.com/ubuntu jammy/main amd64 Packages [1792 kB]
# Get:6 http://archive.ubuntu.com/ubuntu jammy/universe amd64 Packages [17.5 MB]
# Get:7 http://security.ubuntu.com/ubuntu jammy-security/restricted amd64 Packages [4964 kB]
# Get:8 http://security.ubuntu.com/ubuntu jammy-security/multiverse amd64 Packages [48.5 kB]
# Get:9 http://security.ubuntu.com/ubuntu jammy-security/main amd64 Packages [3157 kB]      
# Get:10 http://security.ubuntu.com/ubuntu jammy-security/universe amd64 Packages [1267 kB]  
# Get:11 http://archive.ubuntu.com/ubuntu jammy/restricted amd64 Packages [164 kB]           
# Get:12 http://archive.ubuntu.com/ubuntu jammy/multiverse amd64 Packages [266 kB]
# Get:13 http://archive.ubuntu.com/ubuntu jammy-updates/restricted amd64 Packages [5155 kB]
# Get:14 http://archive.ubuntu.com/ubuntu jammy-updates/multiverse amd64 Packages [75.9 kB]
# Get:15 http://archive.ubuntu.com/ubuntu jammy-updates/universe amd64 Packages [1572 kB]
# Get:16 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages [3468 kB]
# Get:17 http://archive.ubuntu.com/ubuntu jammy-backports/universe amd64 Packages [35.2 kB]
# Get:18 http://archive.ubuntu.com/ubuntu jammy-backports/main amd64 Packages [83.2 kB]
# Fetched 40.2 MB in 9s (4532 kB/s)                                                                                                                                                                                                                                     
# Reading package lists... Done
# INSIDE CONTAINER: CONTAINER has been modified, ready to save as new IMAGE

# Step 4: Commit the modified CONTAINER to create a new IMAGE
# Getting image source signatures
# Copying blob sha256:3cc982388b71ef357e0157e0b7d3059dcefa4dc9fd2e3815bde6c6ce040302f3
# Copying blob sha256:330b45693557dbf1bb31edb2aacfff39de99dcc6b53139f9a0956927ecf83515
# Copying config sha256:6638660dec162e9e28469eb3e3bd32564cfa6761fb8fc6215e306b8b7e7ccbf0
# Writing manifest to image destination
# 6638660dec162e9e28469eb3e3bd32564cfa6761fb8fc6215e306b8b7e7ccbf06638660dec162e9e28469eb3e3bd32564cfa6761fb8fc6215e306b8b7e7ccbf0

# Step 5: Verify our new custom IMAGE was created
# REPOSITORY                          TAG         IMAGE ID      CREATED         SIZE
# localhost/img-stage-00-base-ubuntu  latest      6638660dec16  11 seconds ago  146 MB
# docker.io/library/ubuntu            22.04       1d3ca894b30c  7 days ago      80.4 MB

# Step 6: Clean up - remove the temporary CONTAINER (we keep the IMAGE)
# con-stage-00-base-ubuntu

# Step 7: Final verification - show what we have
# CONCEPT: We started with ubuntu:22.04 IMAGE (template)
# CONCEPT: We created a CONTAINER (running copy) from that IMAGE
# CONCEPT: We modified the CONTAINER by running commands inside it
# CONCEPT: We saved the modified CONTAINER as img-stage-00-base-ubuntu IMAGE
# CONCEPT: Now we have a new IMAGE template ready for stage-01
# REPOSITORY                          TAG         IMAGE ID      CREATED         SIZE
# localhost/img-stage-00-base-ubuntu  latest      6638660dec16  12 seconds ago  146 MB
# docker.io/library/ubuntu            22.04       1d3ca894b30c  7 days ago      80.4 MB

# Total elapsed time: 00:41 (MM:SS)