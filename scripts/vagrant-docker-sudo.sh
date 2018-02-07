#!/bin/sh

# Wrapper script (Linux host only). Allows Vagrant to issue Docker commands
# without having to permanently add your user to the "docker" group.
#
# To use it:
# - Make sure it is executable:
#     chmod +x ~/.CodeEnigma/ce-vm/ce-vm-upstream/scripts/vagrant-docker-sudo.sh
# - Add it as an alias in your bashrc, zshrc, ... eg:
#     alias vg="$HOME/.CodeEnigma/ce-vm/ce-vm-upstream/scripts/vagrant-docker-sudo.sh"
# 
# You will then be able to call "vg up", "vg ssh" as your normal user.
# Note that you will still be prompted for your 'sudoer' password, this is
# needed to add you temporarily to the "docker" group.

# Check if we are running as root.
if [ "$(id -u)" -lt "1" ]; then
   echo "This script must not be run as root. You will get prompted for sudo access during the process."
   exit 1
fi

# Get own path.
OWN=$(readlink "$0");
if [ -z "$OWN" ]; then
 OWN="$0"
fi
OWN_DIR=$( cd "$( dirname "$OWN" )" && pwd -P)
CURRENT_CALL_DIR=$(pwd -P)
VAGRANT_WRAPPER_CMD="/bin/sh $OWN_DIR/vagrant-wrapper.sh"
ORIG_USER="$USER"
sudo gpasswd -a "$ORIG_USER" "docker"
sudo su - -l "$ORIG_USER" -c "cd $CURRENT_CALL_DIR && $VAGRANT_WRAPPER_CMD $@" 
sudo gpasswd -d "$ORIG_USER" "docker"
