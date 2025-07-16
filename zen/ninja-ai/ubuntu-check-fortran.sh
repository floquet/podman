#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

counter=0; subcounter=0; start_time=${SECONDS}
function new_step() { counter=$((counter+1)); subcounter=0; echo -e "\nStep ${counter}: $1"; }
function sub_step() { subcounter=$((subcounter+1)); echo -e "\n  Substep ${counter}.${subcounter}: $1"; }
function elapsed()  { secs=$((SECONDS-start_time)); printf "\nTotal elapsed time: %02d:%02d (MM:SS)\n" $((secs/60)) $((secs%60)); }

TARGET_DIR="/workspace/podman/zen/ninja-ai/logs/fortran-check-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TARGET_DIR"

new_step "Check Fortran compiler installation"
    sub_step "gfortran --version"
              gfortran --version
    sub_step "gfortran -v (verbose info)"
              gfortran -v
    sub_step "which gfortran (location)"
              which gfortran

new_step "Check Coarray Fortran (CAF) tools"
    sub_step "caf --version"
              caf --version || echo "caf command not found"   
    sub_step "cafrun --version"
              cafrun --version || echo "cafrun command not found"    
    sub_step "which caf (location)"
              which caf || echo "caf not in PATH"    
    sub_step "which cafrun (location)"
              which cafrun || echo "cafrun not in PATH"

new_step "Check Intel tools"
    sub_step "ifx --version"
              ifx --version || echo "ifx command not found"
    sub_step "icx --version"
              icx --version || echo "cafrun command not found"
    sub_step "icpx --version"
              icpx --version || echo "cafrun command not found"
    sub_step "which ifx (location)"
              which   || echo "ifx not in PATH"   
    sub_step "which icx (location)"
              which icx || echo "icx not in PATH"
    sub_step "which icpx (location)"
              which icpx || echo "icpx not in PATH"

new_step "Check OpenCoarrays installation"
    sub_step "opencoarrays --version"
              opencoarrays --version || echo "opencoarrays command not found"
    
    sub_step "Find OpenCoarrays files"
        find /usr -name "*coarray*" 2>/dev/null || echo "No coarray files found in /usr"

new_step "Test Fortran compilation"
    sub_step "Create simple Fortran test program"
        echo 'program test
  print *, "Hello Fortran from gfortran!"
  print *, "Compiler version check successful"
end program test' > "$TARGET_DIR/test.f90"
    
    sub_step "Compile Fortran test"
        gfortran "$TARGET_DIR/test.f90" -o "$TARGET_DIR/test"
    
    sub_step "Run Fortran test"
        "$TARGET_DIR/test"

new_step "Test Coarray Fortran compilation"
    sub_step "Create coarray test program"
        echo 'program cotest
  implicit none
  integer :: me[*]
  me = this_image()
  print *, "Hello from Coarray Fortran!"
  print *, "This is image", me, "of", num_images()
end program cotest' > "$TARGET_DIR/cotest.f90"
    
    sub_step "Attempt coarray compilation with caf"
        if command -v caf &> /dev/null; then
            caf "$TARGET_DIR/cotest.f90" -o "$TARGET_DIR/cotest"
            echo "Coarray compilation successful"
        else
            echo "caf compiler not available - trying gfortran with coarray flags"
            gfortran -fcoarray=single "$TARGET_DIR/cotest.f90" -o "$TARGET_DIR/cotest_single" || echo "Coarray compilation failed"
        fi
    
    sub_step "Run coarray test"
        if [ -f "$TARGET_DIR/cotest" ]; then
            cafrun -n 2 "$TARGET_DIR/cotest" || echo "cafrun failed, trying direct execution"
            "$TARGET_DIR/cotest" || echo "Direct coarray execution failed"
        elif [ -f "$TARGET_DIR/cotest_single" ]; then
            "$TARGET_DIR/cotest_single"
        else
            echo "No coarray executable to test"
        fi

new_step "MPI libraries"
    sub_step "ls -la /usr/lib/x86_64-linux-gnu/libmpi*"
              ls -la /usr/lib/x86_64-linux-gnu/libmpi*
    sub_step "ls -la /usr/lib/x86_64-linux-gnu/openmpi/lib/"
              ls -la /usr/lib/x86_64-linux-gnu/openmpi/lib/

new_step "System information"
    sub_step "Operating system info"
        cat /etc/os-release
    
    sub_step "Available compilers"
        ls -la /usr/bin/*fortran* /usr/bin/*gfortran* 2>/dev/null || echo "No additional Fortran compilers found"

elapsed
