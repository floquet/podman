#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# PURPOSE: Recreate Podman VM with storage redirected to external Samsung T7 drive
# NOTE:    Injects config into correct CoreOS path inside VM: /var/home/core/.config/containers/storage.conf

counter=0; subcounter=0; start_time=${SECONDS}
function new_step()    { counter=$((counter+1)); subcounter=0; echo -e "\nStep ${counter}: $1"; }
function sub_step()    { subcounter=$((subcounter+1)); echo -e "\n  Substep ${counter}.${subcounter}: $1"; }
function elapsed()     { secs=$((SECONDS-start_time)); printf "\nTotal elapsed time: %02d:%02d (MM:SS)\n" $((secs/60)) $((secs%60)); }
function run_cmd()     { echo "$*"; eval "$@"; }

EXTERNAL_MOUNT="/Volumes/samsung-t7-shield-boot-ubuntu-24.02"
PODMAN_DIR="${EXTERNAL_MOUNT}/podman-storage"
MACHINE_NAME="xiuhcoatl-ext"

echo
echo "External mount:   $EXTERNAL_MOUNT"
echo "Podman data dir:  $PODMAN_DIR"
echo

read -p "Are these values correct? Press ENTER to continue or Ctrl-C to abort..."

# Step 1: Remove any existing Podman machine
new_step "Remove existing Podman machine (if any)"
run_cmd podman machine stop "$MACHINE_NAME"
run_cmd podman machine rm --force "$MACHINE_NAME"

# Step 2: Prepare external storage directory
new_step "Create external podman-storage directory"
run_cmd mkdir -p "$PODMAN_DIR"
run_cmd chmod 755 "$PODMAN_DIR"

# Step 3: Create new Podman VM with volume mount
new_step "Create new Podman VM with external volume mounted"
run_cmd podman machine init \
    --cpus 10 \
    --memory 24576 \
    --volume "$EXTERNAL_MOUNT":"$EXTERNAL_MOUNT":rw \
    "$MACHINE_NAME"

# Step 4: Start the Podman VM
new_step "Start Podman VM"
run_cmd podman machine start "$MACHINE_NAME"

# Step 5: Inject storage.conf into the correct location inside the VM
new_step "Inject storage.conf into /var/home/core/.config/containers inside VM"

STORAGE_CONF_CONTENT=$(cat <<EOF
[storage]
driver = "overlay"
runroot = "/run/containers"
graphroot = "$PODMAN_DIR"

[storage.options]
additionalimagestores = []

[storage.options.overlay]
mountopt = "nodev,metacopy=on"
EOF
)

# Create config directory and inject config file
run_cmd podman machine ssh "$MACHINE_NAME" -- mkdir -p /var/home/core/.config/containers
echo "$STORAGE_CONF_CONTENT" | podman machine ssh "$MACHINE_NAME" -- tee /var/home/core/.config/containers/storage.conf > /dev/null

# Step 6: Restart VM to apply changes
new_step "Restart Podman VM"
run_cmd podman machine stop "$MACHINE_NAME"
run_cmd podman machine start "$MACHINE_NAME"

# Step 7: Verify that storage is correctly redirected
new_step "Verify Podman is using external storage"
run_cmd podman info | grep -A 10 "store"

elapsed

