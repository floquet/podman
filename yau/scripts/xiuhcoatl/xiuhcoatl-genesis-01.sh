#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# PURPOSE: Obliterate internal Podman state and configure Podman to use external Samsung T7 drive
# NOTE:    This setup gives Podman full use of the external drive with no virtual disk size limits

counter=0; subcounter=0; start_time=${SECONDS}
function new_step()    { counter=$((counter+1)); subcounter=0; echo -e "\nStep ${counter}: $1"; }
function sub_step()    { subcounter=$((subcounter+1)); echo -e "\n  Substep ${counter}.${subcounter}: $1"; }
function elapsed()     { secs=$((SECONDS-start_time)); printf "\nTotal elapsed time: %02d:%02d (MM:SS)\n" $((secs/60)) $((secs%60)); }
function run_cmd()     { echo "$*"; eval "$@"; }

# Define external mount point and storage directory
EXTERNAL_MOUNT="/Volumes/samsung-t7-shield-boot-ubuntu-24.02"
PODMAN_DIR="${EXTERNAL_MOUNT}/podman-storage"

echo
echo "External mount:   $EXTERNAL_MOUNT"
echo "Podman data dir:  $PODMAN_DIR"
echo

read -p "Are these values correct? Press ENTER to continue or Ctrl-C to abort..."

# Step 1: Stop and remove existing Podman VM
new_step "Stop and remove Podman VM"
run_cmd podman machine stop
run_cmd podman machine rm --force

# Step 2: Delete Podman config and cache directories from internal drive
new_step "Delete internal Podman config and cache"
run_cmd rm -rf ~/.config/containers
run_cmd rm -rf ~/.local/share/containers
run_cmd rm -rf ~/.local/share/podman
run_cmd rm -rf ~/.cache/containers

# Step 3: Create new Podman config directory
new_step "Create Podman config directory"
run_cmd mkdir -p ~/.config/containers

# Step 4: Create and prepare external podman-storage directory
new_step "Create podman-storage directory on external volume"
run_cmd mkdir -p "$PODMAN_DIR"

new_step "Set permissions on podman-storage directory"
run_cmd chmod 755 "$PODMAN_DIR"

# Step 5: Write storage.conf pointing to external drive
new_step "Write ~/.config/containers/storage.conf"
run_cmd tee ~/.config/containers/storage.conf > /dev/null <<EOF
[storage]
driver = "overlay"
runroot = "/run/user/1000/containers"
graphroot = "$PODMAN_DIR"

[storage.options]
additionalimagestores = []

[storage.options.overlay]
mountopt = "nodev,metacopy=on"
EOF

# Step 6: Create new Podman VM using external volume
new_step "Create Podman VM with full access to external drive"
run_cmd podman machine init \
    --cpus 10 \
    --memory 24576 \
    --volume "$EXTERNAL_MOUNT":"$EXTERNAL_MOUNT":rw \
    xiuhcoatl-ext

# Step 7: Start the new Podman VM
new_step "Start new Podman VM"
run_cmd podman machine start xiuhcoatl-ext

# Step 8: Verify Podman storage location
new_step "Verify Podman is using external storage"
run_cmd podman info | grep -A 10 "store"

elapsed

