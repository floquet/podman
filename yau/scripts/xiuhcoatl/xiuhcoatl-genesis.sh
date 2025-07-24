#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# xiuhcoatl-podman-migration-no-redundancy.sh
# KEY PRINCIPLE: No redundant numbering - steps and substeps ONLY

counter=0; subcounter=0; start_time=${SECONDS}
function new_step() { counter=$((counter+1)); subcounter=0; echo -e "\n$(tput setaf 6)Step ${counter}: $1$(tput sgr0)"; }
function sub_step() { subcounter=$((subcounter+1)); echo -e "\n  $(tput setaf 3)${counter}.${subcounter}: $1$(tput sgr0)"; }
function echo_cmd() { echo -e "\n$(tput setaf 7)\$ $1$(tput sgr0)"; eval "$1"; }

# ------------------------------------------------------------------------------
new_step "WARNING: This will DESTROY all Podman data"
echo "• Deletes containers/images"
echo "• Configures storage at:"
echo "  /Volumes/samsung-t7-shield-boot-ubuntu-24.02/podman-storage"
read -p "Continue? (y/N) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi

# ------------------------------------------------------------------------------
new_step "Purge existing Podman data"
sub_step "List running containers (reference)"
echo_cmd "podman ps -a"

sub_step "Stop all containers"
echo_cmd "podman stop -a || echo 'No containers to stop'"

sub_step "Remove all containers"
echo_cmd "podman rm -a || echo 'No containers to remove'"

sub_step "Nuclear reset"
echo_cmd "podman system reset --force"

# ------------------------------------------------------------------------------
new_step "Configure external storage"
EXT_ROOT="/Volumes/samsung-t7-shield-boot-ubuntu-24.02"
PODMAN_STORAGE="${EXT_ROOT}/podman-storage"

sub_step "Create storage directory"
echo_cmd "mkdir -pv \"${PODMAN_STORAGE}\""
echo_cmd "chmod -v 755 \"${PODMAN_STORAGE}\""

sub_step "Generate storage.conf"
CONFIG_FILE=~/.config/containers/storage.conf
echo_cmd "cat > \"$CONFIG_FILE\" << EOF
[storage]
driver = \"overlay\"
graphroot = \"${PODMAN_STORAGE}\"
EOF"

# ------------------------------------------------------------------------------
new_step "Verification"
sub_step "Show configuration"
echo_cmd "cat \"$CONFIG_FILE\""

sub_step "Start Podman VM (macOS)"
echo_cmd "podman machine start"

sub_step "Verify storage path"
echo_cmd "podman info --format '{{.Store.GraphRoot}}'"

elapsed
