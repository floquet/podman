#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# xiuhcoatl-podman-migration-teaching-script.sh
# KEY PRINCIPLE: Every destructive command is printed before execution
#                so you can verify before proceeding.

counter=0; subcounter=0; start_time=${SECONDS}
function new_step() { counter=$((counter+1)); subcounter=0; echo -e "\n$(tput setaf 6)Step ${counter}: $1$(tput sgr0)"; }
function sub_step() { subcounter=$((subcounter+1)); echo -e "\n  $(tput setaf 3)Substep ${counter}.${subcounter}: $1$(tput sgr0)"; }
function echo_cmd() { echo -e "\n$(tput setaf 7)\$ $1$(tput sgr0)"; eval "$1"; }  # Print -> Execute

# ==============================================================================
# PHASE 0: WARNING
# ==============================================================================
new_step "=== WARNING ==="
echo "This script will:"
echo "1. DESTROY all existing Podman containers/images"
echo "2. Configure Podman to use external SSD at:"
echo "   /Volumes/samsung-t7-shield-boot-ubuntu-24.02/podman-storage"
read -p "Continue? (y/N) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi

# ==============================================================================
# PHASE 1: PURGE (with confirmation for each destructive operation)
# ==============================================================================
new_step "PHASE 1: Purge existing Podman data"

sub_step "List running containers (for reference)"
echo_cmd "podman ps -a"

sub_step "STOP all running containers"
echo_cmd "podman stop -a || echo 'No containers to stop'"

sub_step "REMOVE all containers"
echo_cmd "podman rm -a || echo 'No containers to remove'"

sub_step "Remove ALL Podman images/volumes/caches"
echo_cmd "podman system reset --force"

sub_step "Purge default storage locations"
locations=(
    ~/.local/share/containers
    ~/.config/containers
    /run/user/$(id -u)/containers
)
for location in "${locations[@]}"; do
    if [ -d "$location" ]; then
        echo -e "\nFound directory: $(tput setaf 1)$location$(tput sgr0)"
        read -p "Delete? (y/N) " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo_cmd "rm -rfv \"$location\""
        fi
    fi
done

# ==============================================================================
# PHASE 2: SETUP (external storage)
# ==============================================================================
new_step "PHASE 2: Configure external storage"

EXT_ROOT="/Volumes/samsung-t7-shield-boot-ubuntu-24.02"
PODMAN_STORAGE="${EXT_ROOT}/podman-storage"

sub_step "Create storage directory on external SSD"
echo_cmd "mkdir -pv \"${PODMAN_STORAGE}\""
echo_cmd "chmod -v 755 \"${PODMAN_STORAGE}\""

sub_step "Generate storage.conf configuration"
CONFIG_FILE=~/.config/containers/storage.conf
echo_cmd "mkdir -pv \"$(dirname "$CONFIG_FILE")\""
echo_cmd "cat > \"$CONFIG_FILE\" << EOF
[storage]
driver = \"overlay\"
runroot = \"/run/user/$(id -u)/containers\"
graphroot = \"${PODMAN_STORAGE}\"

[storage.options]
additionalimagestores = []

[storage.options.overlay]
mountopt = \"nodev,metacopy=on\"
EOF"

# ==============================================================================
# PHASE 3: VERIFICATION
# ==============================================================================
new_step "PHASE 3: Verification"

sub_step "Show generated configuration"
echo_cmd "cat \"$CONFIG_FILE\""

sub_step "Verify Podman recognizes new storage"
echo_cmd "podman info --format '{{.Store.GraphRoot}}'"

sub_step "Test with a disposable container"
echo_cmd "podman run --rm hello-world"
