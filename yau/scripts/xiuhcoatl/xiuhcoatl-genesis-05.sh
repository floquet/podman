#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# PURPOSE: Create Podman VM named samsung-t7-shield with all storage on external SSD
# NOTE: VM mount point is inside user-writable path (/var/home/core/podman-external)

counter=0; subcounter=0; start_time=${SECONDS}
function new_step()    { counter=$((counter+1)); subcounter=0; echo -e "\nStep ${counter}: $1"; }
function sub_step()    { subcounter=$((subcounter+1)); echo -e "\n  Substep ${counter}.${subcounter}: $1"; }
function elapsed()     { secs=$((SECONDS-start_time)); printf "\nTotal elapsed time: %02d:%02d (MM:SS)\n" $((secs/60)) $((secs%60)); }
function run_cmd()     { echo "$*"; eval "$@"; }

EXTERNAL_MOUNT="/Volumes/samsung-t7-shield-boot-ubuntu-24.02"
VM_MOUNT_PATH="/var/home/core/podman-external"
PODMAN_DIR="${VM_MOUNT_PATH}/podman-storage"
MACHINE_NAME="samsung-t7-shield"

echo
echo "External mount (host):   $EXTERNAL_MOUNT"
echo "VM mount path:           $VM_MOUNT_PATH"
echo "Podman storage path:     $PODMAN_DIR"
echo "VM name:                 $MACHINE_NAME"
echo

read -p "Are these values correct? Press ENTER to continue or Ctrl-C to abort..."

# Step 1: Remove existing Podman machine
new_step "Remove existing Podman machine (if any)"
run_cmd podman machine stop "$MACHINE_NAME"
run_cmd podman machine rm --force "$MACHINE_NAME"

# Step 2: Purge and prepare external directory
new_step "Purge old podman-storage directory (host-side)"
run_cmd rm -rf "${EXTERNAL_MOUNT}/podman-storage"

new_step "Create fresh podman-storage directory on external drive"
run_cmd mkdir -p "${EXTERNAL_MOUNT}/podman-storage"
run_cmd chmod 755 "${EXTERNAL_MOUNT}/podman-storage"

# Step 3: Create new Podman VM with volume mount into writable path
new_step "Create new Podman VM with external volume mounted to user-owned path inside VM"
run_cmd podman machine init \
    --cpus 10 \
    --memory 24576 \
    --volume "$EXTERNAL_MOUNT":"$VM_MOUNT_PATH":rw \
    "$MACHINE_NAME"

# Step 4: Start the VM
new_step "Start Podman VM"
run_cmd podman machine start "$MACHINE_NAME"

# Step 5: Inject corrected storage.conf inside the VM
new_step "Inject fixed storage.conf into VM"

STORAGE_CONF_CONTENT=$(cat <<EOF
[storage]
driver = "overlay"
runroot = "/var/tmp/podman-run"
graphroot = "$PODMAN_DIR"

[storage.options]
additionalimagestores = []

[storage.options.overlay]
mountopt = "nodev,metacopy=on"
EOF
)

run_cmd podman machine ssh "$MACHINE_NAME" -- mkdir -p /var/home/core/.config/containers
echo "$STORAGE_CONF_CONTENT" | podman machine ssh "$MACHINE_NAME" -- tee /var/home/core/.config/containers/storage.conf > /dev/null

# Step 6: Restart VM
new_step "Restart Podman VM to apply new configuration"
run_cmd podman machine stop "$MACHINE_NAME"
run_cmd podman machine start "$MACHINE_NAME"

# Step 7: Reconnect host CLI to correct socket
new_step "Reconfigure podman CLI connection"
PORT=$(lsof -iTCP -sTCP:LISTEN -nP | grep -i podman | grep 127.0.0.1 | awk -F: '{print $2}' | awk '{print $1}' | head -n1)
run_cmd podman system connection remove "$MACHINE_NAME"
run_cmd podman system connection add "$MACHINE_NAME" \
  "ssh://core@127.0.0.1:${PORT}/run/user/501/podman/podman.sock" \
  --default

# Step 8: Verify Podman is using external storage
new_step "Verify graphroot path via podman info"
run_cmd podman info | grep -A 10 "store"

elapsed

