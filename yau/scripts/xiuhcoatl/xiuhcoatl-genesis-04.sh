#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# PURPOSE: Configure Podman to use external SSD for container storage via valid VM mount point
# NOTE: Uses /mnt/podman inside VM and a writable runroot

counter=0; subcounter=0; start_time=${SECONDS}
function new_step()    { counter=$((counter+1)); subcounter=0; echo -e "\nStep ${counter}: $1"; }
function sub_step()    { subcounter=$((subcounter+1)); echo -e "\n  Substep ${counter}.${subcounter}: $1"; }
function elapsed()     { secs=$((SECONDS-start_time)); printf "\nTotal elapsed time: %02d:%02d (MM:SS)\n" $((secs/60)) $((secs%60)); }
function run_cmd()     { echo "$*"; eval "$@"; }

EXTERNAL_MOUNT="/Volumes/samsung-t7-shield-boot-ubuntu-24.02"
MOUNTPOINT_VM="/mnt/podman"
PODMAN_DIR="${MOUNTPOINT_VM}/podman-storage"
MACHINE_NAME="xiuhcoatl-ext"

echo
echo "External mount:   $EXTERNAL_MOUNT"
echo "VM mount point:   $MOUNTPOINT_VM"
echo "Podman data dir:  $PODMAN_DIR"
echo

read -p "Are these values correct? Press ENTER to continue or Ctrl-C to abort..."

# Step 1: Remove existing Podman machine
new_step "Remove existing Podman machine (if any)"
run_cmd podman machine stop "$MACHINE_NAME"
run_cmd podman machine rm --force "$MACHINE_NAME"

# Step 2: Prepare host-side external directory
new_step "Ensure host-side external podman-storage exists"
run_cmd mkdir -p "${EXTERNAL_MOUNT}/podman-storage"
run_cmd chmod 755 "${EXTERNAL_MOUNT}/podman-storage"

# Step 3: Create new Podman VM with correct volume mount
new_step "Create new Podman VM with external volume mounted to VM-accessible path"
run_cmd podman machine init \
    --cpus 10 \
    --memory 24576 \
    --volume "$EXTERNAL_MOUNT":"$MOUNTPOINT_VM":rw \
    "$MACHINE_NAME"

# Step 4: Start the Podman VM
new_step "Start Podman VM"
run_cmd podman machine start "$MACHINE_NAME"

# Step 5: Inject valid storage.conf inside the VM
new_step "Inject corrected storage.conf into /var/home/core/.config/containers inside VM"

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

# Step 6: Restart VM cleanly
new_step "Restart VM to activate storage configuration"
run_cmd podman machine stop "$MACHINE_NAME"
run_cmd podman machine start "$MACHINE_NAME"

# Step 7: Reconnect host CLI to correct socket (if needed)
new_step "Reconfigure podman system connection"
PORT=$(podman machine inspect "$MACHINE_NAME" --format '{{.SSH.RemotePort}}')
run_cmd podman system connection remove "$MACHINE_NAME"
run_cmd podman system connection add "$MACHINE_NAME" \
    "ssh://core@127.0.0.1:${PORT}/run/user/501/podman/podman.sock" \
    --default

# Step 8: Verify Podman is using external storage
new_step "Verify storage configuration via podman info"
run_cmd podman info | grep -A 10 "store"

elapsed

