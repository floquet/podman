#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# Install prerequisites
apt-get update
apt-get upgrade -y
#apt-get install -y build-essential wget flex bison libgmp-dev libmpfr-dev libmpc-dev

# Create directory for GCC builds
mkdir -p /opt/gcc-builds && cd /opt/gcc-builds

# Function to build specific GCC version
build_gcc() {
  VERSION=$1
  echo "Building GCC $VERSION..."
  
  # Download and extract
  wget https://ftp.gnu.org/gnu/gcc/gcc-$VERSION/gcc-$VERSION.tar.gz
  tar xf gcc-$VERSION.tar.gz
  cd gcc-$VERSION
  
  # Download prerequisites
  ./contrib/download_prerequisites
  
  # Create build directory
  mkdir build && cd build
  
  # Configure
  ../configure --prefix=/opt/gcc-$VERSION --enable-languages=c,c++,fortran --disable-multilib
  
  # Build and install
  make -j$(nproc)
  make install
  
  # Create symlinks
  ln -sf /opt/gcc-$VERSION/bin/gcc /usr/local/bin/gcc-$VERSION
  ln -sf /opt/gcc-$VERSION/bin/g++ /usr/local/bin/g++-$VERSION
  ln -sf /opt/gcc-$VERSION/bin/gfortran /usr/local/bin/gfortran-$VERSION
  
  cd /opt/gcc-builds
}

# Build GCC versions
build_gcc 12.3.0
build_gcc 13.2.0
build_gcc 14.1.0
build_gcc 15.1.0  # Note: Use actual version when available
