#!/usr/bin/env bash
# build-gcc-15.1.sh
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <target-dir>"
    echo "Example: $0 /workspace/gcc-15.1-build"
    exit 1
fi

TARGET_DIR="$1"
GCC_VERSION="15.1.0"
PREFIX="/opt/gcc-${GCC_VERSION}"
BUILD_DIR="$TARGET_DIR/gcc-build"
SOURCE_DIR="$TARGET_DIR/gcc-${GCC_VERSION}"

counter=0; start_time=${SECONDS}
function new_step() { counter=$((counter+1)); echo -e "\nStep ${counter}: $1"; }
function elapsed()  { secs=$((SECONDS-start_time)); printf "\nTotal elapsed time: %02d:%02d (MM:SS)\n" $((secs/60)) $((secs%60)); }

new_step "Create build directories"
mkdir -p "$TARGET_DIR" "$BUILD_DIR"
cd "$TARGET_DIR"
