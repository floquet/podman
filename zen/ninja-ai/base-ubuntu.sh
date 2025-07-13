#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# source /home/user/repos-xiuhcoatl/github/podman/zen/ninja-ai/base-ubuntu.sh 2>&1 | tee /home/user/repos-xiuhcoatl/github/podman/zen/ninja-ai/base-ubuntu-$(date +%Y%m%d_%H%M%S).txt

counter=0; subcounter=0; start_time=${SECONDS}
function new_step() { counter=$((counter+1)); subcounter=0; echo -e "\nStep ${counter}: $1"; }
function sub_step() { subcounter=$((subcounter+1)); echo -e "\n  Substep ${counter}.${subcounter}: $1"; }
function elapsed()  { secs=$((SECONDS-start_time)); printf "\nTotal elapsed time: %02d:%02d (MM:SS)\n" $((secs/60)) $((secs%60)); }

echo "System settings to select: Region 2 (Americas), Timezone 47 (Denver)"

new_step "Update package manager: apt-get update && apt-get upgrade -y"
apt-get update && apt-get upgrade -y

# Region: 2 (Americas)
# Time zone: 49 (Denver)

new_step "Define essential build tools and dependencies"
essential_packages=(
  autoconf
  automake
  bison
  build-essential
  cmake
  curl
  flex
  git
  libisl-dev
  libgmp-dev
  libmpc-dev
  libmpfr-dev
  libzstd-dev
  libtool
  nano
  ninja-build
  pkg-config
  python3
  python3-pip
  software-properties-common
  texinfo
  vim
  wget
  zlib1g-dev
)

new_step "Define development versions of compilers"
compiler_packages=(
  # Core compilers
  clang
  flang
  g++
  gcc
  gfortran
  
  # C++ standard library support
  libc++-dev
  libc++abi-dev
  
  # Coarray Fortran support
  libcoarrays-dev
  libcoarrays-mpich-dev
  libcoarrays-openmpi-dev
  
  # OpenMP support
  libgomp1
  libomp-dev
  libomp5
  
  # MPI libraries
  libmpich-dev
  libopenmpi-dev
  mpich
  openmpi-bin
  openmpi-common
  
  # CUDA toolkit
  nvidia-cuda-dev
  nvidia-cuda-gdb
  nvidia-cuda-toolkit
  
  # Scientific computing languages
  julia
  octave
)

new_step "Define diagnostic packages"
diagnostics_packages=(
  coz-profiler
  gdb
  google-perftools
  heaptrack
  heaptrack-gui
  htop
  iotop
  kcachegrind
  libgoogle-perftools-dev
  libgprofng0
  libpapi-dev
  ltrace
  man-db
  manpages
  manpages-dev
  massif-visualizer
  oprofile
  strace
  sysprof
  sysstat
  valgrind
  valgrind-mpi
)


function install_packages() {
  local step_name="$1"
  local -n packages=$2
  
  new_step "$step_name"
  for package in "${packages[@]}"; do
    sub_step "apt-get install $package"
    apt-get install -y "$package"
    sub_step "apt-cache show $package"
    apt-cache show "$package" > "$TARGET_DIR/show/$package.txt" &
    sub_step "apt-cache depends $package"
    apt-cache depends "$package" > "$TARGET_DIR/depends/$package.txt" &
    sub_step "apt-cache policy $package"
    apt-cache policy "$package" > "$TARGET_DIR/policy/$package.txt" &
  done
  wait  # Wait for background apt-cache commands
}

new_step "Set up alternatives for easy switching"
# Get actual installed versions dynamically
GCC_VER=$(gcc --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1 | cut -d. -f1)
CLANG_VER=$(clang --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1 | cut -d. -f1)
sub_step "GCC_VER   = ${GCC_VER}"
sub_step "CLANG_VER = ${CLANG_VER}"

sub_step "Setting up GCC alternatives"
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VER} 100
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${GCC_VER} 100
update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-${GCC_VER} 100

sub_step "Setting up Clang alternatives"
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${CLANG_VER} 100
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${CLANG_VER} 100

new_step "Close with elapsed time"
elapsed
