#!/bin/sh

# Wrapper script (Linux host only). Allows Vagrant to issue Docker commands
# without having to permanently add your user to the "docker" group.
#
# To use it it as an alias in your bashrc, zshrc, ... eg:
# alias vg="/bin/sh $HOME/.CodeEnigma/ce-vm/ce-vm-upstream/scripts/vagrant-docker-sudo.sh"
# 
# You will then be able to call "vg up", "vg ssh" as your normal user.
# Note that you will still be prompted for your 'sudoer' password, this is
# needed to add you temporarily to the "docker" group.

# Check if we are running as root.
if [ "$(id -u)" -lt "1" ]; then
   echo "This script must not be run as root. You will get prompted for sudo access during the process."
   exit 1
fi

ORIG_USER="$USER"

# Ensure group always get removed.
trap "sudo gpasswd -d $ORIG_USER 'docker'" EXIT

# Get own path.
OWN=$(readlink "$0");
if [ -z "$OWN" ]; then
 OWN="$0"
fi
OWN_DIR=$( cd "$( dirname "$OWN" )" && pwd -P)
CURRENT_CALL_DIR=$(pwd -P)
VAGRANT_WRAPPER_CMD="/bin/sh $OWN_DIR/vagrant-wrapper.sh $@"
sudo gpasswd -a "$ORIG_USER" "docker"
sudo su - -l "$ORIG_USER" -c "cd $CURRENT_CALL_DIR && $VAGRANT_WRAPPER_CMD" 
