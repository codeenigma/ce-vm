#!/bin/sh

# Keep current dir in mind to know where to move back when done.
OWN=$(readlink "$0");
if [ -z "$OWN" ]; then
 OWN="$0"
fi
OWN_DIR=$( cd "$( dirname "$OWN" )" && pwd -P)

BUILD_DIR="$OWN_DIR/build"
# Clean existing build if it exists.
if [ -d "$BUILD_DIR" ]; then
  sudo rm -rf "$BUILD_DIR"
fi

# Generate skeleton.
mkdir -p "$BUILD_DIR/ce-vm"
CONFIG_FILE="$BUILD_DIR/ce-vm/config.yml"
PROJECT_TYPE="$1"
VOLUME_TYPE="$2"

# Include project specifics.
. "$OWN_DIR/$PROJECT_TYPE.sh"

# Generate project config.
generate_config

# Start the project.
cd "$BUILD_DIR/ce-vm"
curl -O https://raw.githubusercontent.com/codeenigma/ce-vm-model/5.x/ce-vm/Vagrantfile

export BRANCH=$(if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then echo $TRAVIS_BRANCH; else echo $TRAVIS_PULL_REQUEST_BRANCH; fi)
echo "TRAVIS_BRANCH=$TRAVIS_BRANCH, PR=$TRAVIS_PULL_REQUEST, BRANCH=$BRANCH"

vagrant up || exit 1
vagrant destroy --force || exit 1

# Clean existing build if it exists.
if [ -d "$BUILD_DIR" ]; then
  sudo rm -rf "$BUILD_DIR"
fi
