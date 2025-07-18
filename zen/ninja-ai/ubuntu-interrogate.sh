#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# Create output directory if it doesn't exist
TARGET_DIR="/repos/github/podman/zen/ninja-ai/logs"
mkdir -p ${TARGET_DIR}

# Generate unique filename
CONTAINER_ID=$(hostname)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
INTERROGATE_FILE="${TARGET_DIR}/interrogate_${CONTAINER_ID}_${TIMESTAMP}.txt"

# System and application interrogation
{
    echo "=== SYSTEM INTERROGATION ==="
    echo "Date: $(date)"
    echo "Container ID: $(hostname)"
    echo "Created by: ${BASH_SOURCE[0]}"
    echo ""
    
    echo "=== OPERATING SYSTEM ==="
    cat /etc/os-release
    echo "Kernel: $(uname -a)"
    echo "Architecture: $(arch)"
    echo ""
    
    echo "=== HARDWARE RESOURCES ==="
    echo "CPU Info:"
    lscpu | head -20
    echo ""
    echo "Memory:"
    free -h
    echo ""
    echo "Disk Usage:"
    df -h
    echo ""
    
    echo "=== INSTALLED COMPILERS ==="
    echo "GCC:"
    gcc --version 2>/dev/null || echo "GCC not found"
    echo ""
    echo "G++:"
    g++ --version 2>/dev/null || echo "G++ not found"
    echo ""
    echo "Gfortran:"
    gfortran --version 2>/dev/null || echo "Gfortran not found"
    echo ""
    echo "Clang:"
    clang --version 2>/dev/null || echo "Clang not found"
    echo ""
    echo "Clang++:"
    clang++ --version 2>/dev/null || echo "Clang++ not found"
    echo ""
    
    echo "=== DEVELOPMENT TOOLS ==="
    echo "Make: $(make --version 2>/dev/null | head -1 || echo "Make not found")"
    echo "CMake: $(cmake --version 2>/dev/null | head -1 || echo "CMake not found")"
    echo "Ninja: $(ninja --version 2>/dev/null || echo "Ninja not found")"
    echo "Git: $(git --version 2>/dev/null || echo "Git not found")"
    echo "Python3: $(python3 --version 2>/dev/null || echo "Python3 not found")"
    echo "Pip3: $(pip3 --version 2>/dev/null || echo "Pip3 not found")"
    echo ""
    
    echo "=== INSTALLED PACKAGES (APT) ==="
    dpkg -l | grep -E "(gcc|clang|cmake|ninja|python|git|build)" | head -20
    echo ""
    
    echo "=== ENVIRONMENT VARIABLES ==="
    echo "PATH: $PATH"
    echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
    echo "CC: $CC"
    echo "CXX: $CXX"
    echo "FC: $FC"
    echo ""
    
    echo "=== NETWORK CONFIGURATION ==="
    ip addr show 2>/dev/null || ifconfig 2>/dev/null || echo "Network info not available"
    echo ""
    
    echo "=== RUNNING PROCESSES ==="
    ps aux | head -10
    echo ""
    
    echo "=== MOUNTED FILESYSTEMS ==="
    mount | grep -v "proc\|sys\|dev\|run"
    echo ""
    
    echo "=== ALTERNATIVES CONFIGURATION ==="
    update-alternatives --get-selections 2>/dev/null | grep -E "(gcc|clang|python)" || echo "No alternatives configured"
    
} > "$INTERROGATE_FILE"

echo "System interrogation saved to: $INTERROGATE_FILE"
