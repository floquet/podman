#!/usr/bin/env bash
# xiuhcoatl-create-stage-01.sh
# PURPOSE: Create stage-01 IMAGE by running our apt-get script inside stage-00 IMAGE
# CONCEPT: We take our img-stage-00-base-ubuntu IMAGE (template from previous stage),
#          run it as a CONTAINER, execute our pod-stage-01.sh script inside the CONTAINER,
#          then save the modified CONTAINER as img-stage-01-deluxe-ubuntu IMAGE

printf "%s\n" "$(tput bold)$ (date) ${BASH_SOURCE[0]}$(tput sgr0)"

counter=0; subcounter=0; start_time=${SECONDS}
function new_step() { counter=$((counter+1)); subcounter=0; echo -e "\nStep ${counter}: $1"; }
function sub_step() { subcounter=$((subcounter+1)); echo -e "\n  Substep ${counter}.${subcounter}: $1"; }
function elapsed()  { secs=$((SECONDS-start_time)); printf "\nTotal elapsed time: %02d:%02d (MM:SS)\n" $((secs/60)) $((secs%60)); }

new_step "Verify we have the stage-00 IMAGE to build from"
# CONCEPT: We need img-stage-00-base-ubuntu IMAGE as our starting point
echo "podman images | grep stage-00"
      podman images | grep stage-00

new_step "Create and run CONTAINER from stage-00 IMAGE with full mappings"
# CONCEPT: Starting from img-stage-00-base-ubuntu IMAGE (our previous work)
# CONCEPT: Creating new CONTAINER named con-stage-01-deluxe-ubuntu
# CONCEPT: Using same mappings as your docker setup for consistency
# CONCEPT: Running pod-stage-01.sh INSIDE the CONTAINER to install packages
echo "COMMAND TO LEARN: podman run --name con-stage-01-deluxe-ubuntu \\"
echo "  -v /etc/localtime:/etc/localtime:ro \\"
echo "  -v \"${lrepos}:/repos\" \\"
echo "  -v \"${HOME}/spacklink:/spacktivity\" \\"
echo "  -v \"${HOME}/Dropbox:/Dropbox\" \\"
echo "  img-stage-00-base-ubuntu /bin/bash -c \"source /repos/github/podman/yau/scripts/pod/pod-stage-01.sh\""

podman run --name con-stage-01-deluxe-ubuntu \
  -v /etc/localtime:/etc/localtime:ro \
  -v "${lrepos}:/repos" \
  -v "${HOME}/spacklink:/spacktivity" \
  -v "${HOME}/Dropbox:/Dropbox" \
  img-stage-00-base-ubuntu /bin/bash -c "
    echo 'INSIDE CONTAINER: Starting stage-01 modifications'
    echo 'INSIDE CONTAINER: About to run pod-stage-01.sh with apt-get commands'
    echo 'INSIDE CONTAINER: Container name is:' \$(hostname)
    source /repos/github/podman/yau/scripts/pod/pod-stage-01.sh
    echo 'INSIDE CONTAINER: pod-stage-01.sh completed, CONTAINER now has new packages'
    echo 'INSIDE CONTAINER: Ready to exit and save as IMAGE'
"

new_step "Commit the modified CONTAINER to create stage-01 IMAGE"
# CONCEPT: CONTAINER now has Ubuntu + stage-00 changes + our new apt-get packages
# CONCEPT: Saving this modified CONTAINER as img-stage-01-deluxe-ubuntu IMAGE
# CONCEPT: This IMAGE will be the starting point for stage-02
echo "COMMAND TO LEARN: podman commit con-stage-01-deluxe-ubuntu img-stage-01-deluxe-ubuntu"
                        podman commit con-stage-01-deluxe-ubuntu img-stage-01-deluxe-ubuntu

new_step "Verify our new stage-01 IMAGE was created"
echo "podman images | grep stage-01"
      podman images | grep stage-01

new_step "Clean up - remove the temporary CONTAINER (keep the IMAGE)"
# CONCEPT: CONTAINER was just our workspace, IMAGE is what we keep
echo "COMMAND TO LEARN: podman rm con-stage-01-deluxe-ubuntu"
                        podman rm con-stage-01-deluxe-ubuntu

new_step "Copy-paste commands for future reference"
echo "CONCEPT: Here are the key commands you just learned:"
echo "  TO RUN STAGE-01 INTERACTIVELY:"
echo "  podman run -it --name temp-con-stage-01 \\"
echo "    -v /etc/localtime:/etc/localtime:ro \\"
echo "    -v \"${lrepos}:/repos\" \\"
echo "    -v \"${HOME}/spacklink:/spacktivity\" \\"
echo "    -v \"${HOME}/Dropbox:/Dropbox\" \\"
echo "    img-stage-01-deluxe-ubuntu /bin/bash"
echo ""
echo "  TO SAVE WORK FROM INTERACTIVE SESSION:"
echo "  podman commit temp-con-stage-01 img-stage-01-deluxe-ubuntu-updated"

new_step "Final status - show our IMAGE progression"
echo "CONCEPT: We now have img-stage-01-deluxe-ubuntu IMAGE containing:"
echo "CONCEPT:   - Ubuntu 22.04 base system"
echo "CONCEPT:   - Stage-00 modifications" 
echo "CONCEPT:   - Stage-01 apt-get packages from pod-stage-01.sh"
echo "CONCEPT: This IMAGE is ready to be the foundation for stage-02"
echo "podman images"
      podman images

elapsed

