#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# Update package manager
apt update && apt upgrade -y

# Install essential build tools and dependencies
apt install -y \
  build-essential \
  software-properties-common \
  wget \
  curl \
  git \
  cmake \
  ninja-build \
  python3 \
  python3-pip \
  pkg-config \
  autoconf \
  automake \
  libtool \
  flex \
  bison \
  texinfo \
  libgmp-dev \
  libmpfr-dev \
  libmpc-dev \
  libisl-dev \
  zlib1g-dev \
  libzstd-dev \
  vim \
  nano

# Install development versions of compilers
apt install -y \
  gcc-13 \
  g++-13 \
  gfortran-13 \
  clang-17 \
  clang++-17 \
  libc++-17-dev \
  libc++abi-17-dev

# Set up alternatives for easy switching
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100
update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-13 100
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-17 100
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-17 100