#!/bin/sh

# Wrapper script. Allows you to call vagrant commands on a ce-vm
# project from within any subdirectory.
# This assumes your parent folder is a git repository.
#
# To use it, add it as an alias in your bashrc, zshrc, ... eg:
# alias vg="/bin/sh $HOME/.CodeEnigma/ce-vm/ce-vm-upstream/scripts/vagrant-wrapper.sh"
# 
# You will then be able to call "vg up", "vg ssh" without being in 
# the same directory than the Vagrantfile.

CE_VM_DIR='ce-vm'

# Try to retrieve actual repo, else we'll just pass to vagrant. 
GIT_DIR=$(git rev-parse --show-toplevel 2> /dev/null)
if [ ! -z "$GIT_DIR" ]; then
  VM_DIR="$GIT_DIR/$CE_VM_DIR"
  if [ -d "$VM_DIR" ] && [ -f "$VM_DIR/Vagrantfile" ]; then
    cd "$VM_DIR"
  fi
fi
vagrant $@
