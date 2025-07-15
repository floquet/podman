#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

counter=0; subcounter=0; start_time=${SECONDS}
function new_step() { counter=$((counter+1)); subcounter=0; echo -e "\nStep ${counter}: $1"; }
function sub_step() { subcounter=$((subcounter+1)); echo -e "\n  Substep ${counter}.${subcounter}: $1"; }
function elapsed()  { secs=$((SECONDS-start_time)); printf "\nTotal elapsed time: %02d:%02d (MM:SS)\n" $((secs/60)) $((secs%60)); }

new_step "podman machine start gcc-dev-machine"
    podman machine start gcc-dev-machine

new_step "podman run -it -v /Users/dantopa/repos-xiuhcoatl/github/:/workspace --name spack-dev ubuntu:22.04"
    podman run -it -v /Users/dantopa/repos-xiuhcoatl/github/:/workspace --name spack-dev ubuntu:22.04

new_step "Run pm-save to capture changes"

new_step "exit podman start script"

elapsed
