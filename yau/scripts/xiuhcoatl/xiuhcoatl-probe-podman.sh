#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

counter=0; subcounter=0; start_time=${SECONDS}
function new_step() { counter=$((counter+1)); subcounter=0; echo -e "\nStep ${counter}: $1"; }
function sub_step() { subcounter=$((subcounter+1)); echo -e "\n  Substep ${counter}.${subcounter}: $1"; }
function elapsed()  { secs=$((SECONDS-start_time)); printf "\nTotal elapsed time: %02d:%02d (MM:SS)\n" $((secs/60)) $((secs%60)); }

new_step "Check if Podman is installed: podman --version"
podman --version

new_step "Check Podman system info: podman info"
podman info

new_step "List all containers (running and stopped): podman ps -a"
podman ps -a

new_step "List running containers only: podman ps"
podman ps

new_step "List all images: podman images"
podman images

new_step "Check Podman machine status: podman machine list"
podman machine list

new_step "Show system resources usage: podman system df"
podman system df

new_step "Check if Podman machine is running: podman machine info"
podman machine info

new_step "List available networks: podman network ls"
podman network ls

new_step "Show Podman events (last 10): podman events --since 1h --max-events 10"
podman events --since 1h --max-events 10

elapsed
