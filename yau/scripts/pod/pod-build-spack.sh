#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

counter=0; subcounter=0; start_time=${SECONDS}
function new_step() { counter=$((counter+1)); subcounter=0; echo -e "\nStep ${counter}: $1"; }
function sub_step() { subcounter=$((subcounter+1)); echo -e "\n  Substep ${counter}.${subcounter}: $1"; }
function elapsed()  { secs=$((SECONDS-start_time)); printf "\nTotal elapsed time: %02d:%02d (MM:SS)\n" $((secs/60)) $((secs%60)); }

TARGET_DIR="/workspace/podman/zen/ninja-ai/logs/ubuntu-spack-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TARGET_DIR"

new_step "Create spackuser account"
    sub_step "Add user spackuser"
        useradd -m -s /bin/bash spackuser
    
    sub_step "Add spackuser to sudo group"
        usermod -aG sudo spackuser
    
    sub_step "Set password for spackuser"
        echo "spackuser:spackuser" | chpasswd

new_step "Install Spack as spackuser"
    sub_step "Clone Spack repository"
        su - spackuser -c "cd /home/spackuser && git clone -c feature.manyFiles=true https://github.com/spack/spack.git"
    
    sub_step "Setup Spack environment"
        su - spackuser -c "cd /home/spackuser/spack && . share/spack/setup-env.sh && echo '. /home/spackuser/spack/share/spack/setup-env.sh' >> ~/.bashrc"
    
    sub_step "Find system compilers"
        su - spackuser -c ". /home/spackuser/spack/share/spack/setup-env.sh && spack compiler find"
    
    sub_step "List available compilers"
        su - spackuser -c ". /home/spackuser/spack/share/spack/setup-env.sh && spack compilers" > "$TARGET_DIR/initial-compilers.txt"

new_step "Build OpenCoarrays (pulls in compilers and MPI)"
    sub_step "Install OpenCoarrays with OpenMPI"
        su - spackuser -c ". /home/spackuser/spack/share/spack/setup-env.sh && spack install opencoarrays ^openmpi"
    
    sub_step "Document OpenCoarrays installation"
        su - spackuser -c ". /home/spackuser/spack/share/spack/setup-env.sh && spack find opencoarrays" > "$TARGET_DIR/opencoarrays-install.txt"

new_step "Build Python Astropy"
    sub_step "Install py-astropy"
        su - spackuser -c ". /home/spackuser/spack/share/spack/setup-env.sh && spack install py-astropy"
    
    sub_step "Document Astropy installation"
        su - spackuser -c ". /home/spackuser/spack/share/spack/setup-env.sh && spack find py-astropy" > "$TARGET_DIR/astropy-install.txt"

new_step "Build LLVM"
    sub_step "Install LLVM"
        su - spackuser -c ". /home/spackuser/spack/share/spack/setup-env.sh && spack install llvm"
    
    sub_step "Document LLVM installation"
        su - spackuser -c ". /home/spackuser/spack/share/spack/setup-env.sh && spack find llvm" > "$TARGET_DIR/llvm-install.txt"

new_step "Final documentation"
    sub_step "List all installed packages"
        su - spackuser -c ". /home/spackuser/spack/share/spack/setup-env.sh && spack find" > "$TARGET_DIR/all-spack-packages.txt"
    
    sub_step "List all compilers"
        su - spackuser -c ". /home/spackuser/spack/share/spack/setup-env.sh && spack compilers" > "$TARGET_DIR/final-compilers.txt"
    
    sub_step "System disk usage"
        df -h > "$TARGET_DIR/final-disk-usage.txt"
    
    sub_step "Spack configuration"
        su - spackuser -c ". /home/spackuser/spack/share/spack/setup-env.sh && spack config get" > "$TARGET_DIR/spack-config.yaml"

new_step "Setup complete"
    sub_step "Switch to spackuser"
        echo "To use Spack:"
        echo "  su - spackuser"
        echo "  spack load opencoarrays"
        echo "  spack load py-astropy" 
        echo "  spack load llvm"

elapsed
