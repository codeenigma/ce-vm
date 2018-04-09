#!/bin/sh

# Keep current dir in mind to know where to move back when done.
OWN=$(readlink "$0");
if [ -z "$OWN" ]; then
 OWN="$0"
fi
OWN_DIR=$( cd "$( dirname "$OWN" )" && pwd -P)

mkdir "$OWN_DIR/ce-vm"
cd "$OWN_DIR/ce-vm"
curl -O https://raw.githubusercontent.com/codeenigma/ce-vm-model/5.x/ce-vm/Vagrantfile
echo '---' > config.yml
echo '' >> config.yml
echo "project_type: $1" >> config.yml
echo "project_name: $1" >> config.yml
echo "volume_type: $2" >> config.yml
vagrant up