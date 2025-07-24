#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

counter=0; subcounter=0; start_time=${SECONDS}
function new_step()   { counter=$((counter+1)); subcounter=0; echo -e "\nStep ${counter}: $1"; }
function sub_step()   { subcounter=$((subcounter+1)); echo -e "\n  Substep ${counter}.${subcounter}: $1"; }
function elapsed()    { secs=$((SECONDS-start_time)); printf "\nTotal elapsed time: %02d:%02d (MM:SS)\n" $((secs/60)) $((secs%60)); }

new_step "Verify we have the stage-01 IMAGE to build from"
echo "podman images | grep stage-01"
      podman images | grep stage-01

new_step "Create and run CONTAINER from stage-01 IMAGE, execute Spack installation"
echo "podman run --name con-stage-02-base-spack \\"
echo "  -v /etc/localtime:/etc/localtime:ro \\"
echo "  -v \"${lrepos}:/repos\" \\"
echo "  -v \"${HOME}/spacklink:/spacktivity\" \\"
echo "  -v \"${HOME}/Dropbox:/Dropbox\" \\"
echo "  img-stage-01-deluxe-ubuntu /bin/bash -c \"source /repos/github/podman/yau/scripts/pod/pod-build-spack.sh\""
     podman run --name con-stage-02-base-spack \
       -v /etc/localtime:/etc/localtime:ro \
       -v "${lrepos}:/repos" \
       -v "${HOME}/spacklink:/spacktivity" \
       -v "${HOME}/Dropbox:/Dropbox" \
       img-stage-01-deluxe-ubuntu /bin/bash -c "source /repos/github/podman/yau/scripts/pod/pod-build-spack.sh"

new_step "Commit the modified CONTAINER to create stage-02 IMAGE"
echo "podman commit con-stage-02-base-spack img-stage-02-base-spack"
      podman commit con-stage-02-base-spack img-stage-02-base-spack

new_step "Verify our new stage-02 IMAGE was created"
echo "podman images | grep stage-02"
      podman images | grep stage-02

new_step "Clean up - remove the temporary CONTAINER"
echo "podman rm con-stage-02-base-spack"
      podman rm con-stage-02-base-spack

new_step "Final status - show our IMAGE progression"
echo "podman images"
      podman images

elapsed

