#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# Create output directory if it doesn't exist
mkdir -p /home/user/repos-xiuhcoatl/github/podman/zen/ninja-ai

# Generate unique filename with container ID and timestamp
CONTAINER_ID=$(hostname)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
HISTORY_FILE="/home/user/repos-xiuhcoatl/github/podman/zen/ninja-ai/history_${CONTAINER_ID}_${TIMESTAMP}.txt"

# Write system information for reproducibility
{
    echo "Date: $(date)"
    echo "Container ID: $(hostname)"
    echo "Process ID: $$"
    echo "Parent Process ID: $PPID"
    echo "Current Directory: $PWD"
    echo "User: $(whoami)"
    echo "Shell: $SHELL"
    echo "Bash Version: $BASH_VERSION"
    echo "Created by: ${BASH_SOURCE[0]}"
    echo "OS Info: $(cat /etc/os-release | head -2)"
    echo "Kernel: $(uname -a)"
    echo "Memory: $(free -h | head -2)"
    echo "CPU Cores: $(nproc)"
    echo "Uptime: $(uptime)"
    echo "Environment Variables:"
    env | sort
    echo ""
    echo "=== COMMAND HISTORY ==="
    history
} > "$HISTORY_FILE"

echo "System info and history saved to: $HISTORY_FILE"
