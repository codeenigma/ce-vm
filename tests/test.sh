#!/bin/sh

TESTS="drupal"
for TEST in $TESTS; do
  cd $TEST
  curl -O https://raw.githubusercontent.com/codeenigma/ce-vm-model/5.x/ce-vm/Vagrantfile
  vagrant up
done
