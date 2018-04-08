#!/bin/sh

# Keep current dir in mind to know where to move back when done.
OWN=$(readlink "$0");
if [ -z "$OWN" ]; then
 OWN="$0"
fi
OWN_DIR=$( cd "$( dirname "$OWN" )" && pwd -P)

echo $(id -u travis)
echo $(id -g travis)

TESTS="drupal"
for TEST in $TESTS; do
  cd $OWN_DIR/$TEST
  curl -O https://raw.githubusercontent.com/codeenigma/ce-vm-model/5.x/ce-vm/Vagrantfile
  vagrant up
done
