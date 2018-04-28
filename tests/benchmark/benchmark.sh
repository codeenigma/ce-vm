#!/bin/sh

# Keep current dir in mind to know where to move back when done.
OWN=$(readlink "$0");
if [ -z "$OWN" ]; then
 OWN="$0"
fi
OWN_DIR=$( cd "$( dirname "$OWN" )" && pwd -P)

# Define global config.
BUILD_DIR="$OWN_DIR/build"
RESULT_DIR="$OWN_DIR/results"
RESULT_FILE="$RESULT_DIR/$1.csv"
VAGRANTFILE="$OWN_DIR/Vagrantfile"
CONFIG_YML="$OWN_DIR/config.yml"
VOL_TYPES="native unison"

# Clean existing build if it exists.
if [ -d "$BUILD_DIR" ]; then
  sudo rm -rf "$BUILD_DIR"
fi
# Clean existing results file.
if [ -f "$RESULT_FILE" ]; then
  sudo rm "$RESULT_FILE"
fi

# Abuse the lack of var scope !
start(){
  START_TIME=`date +%s`
}
end(){
  END_TIME=`date +%s`
  RUN_TIME=$((END_TIME-START_TIME))
}

# Include project specifics.
# shellcheck source=./write-mount.sh
. "$OWN_DIR/$1.sh"

# Prepare environment.
mkdir "$BUILD_DIR"
prepare_test

for PASS in `seq 1 $2`; do
  run_test
done

cleanup_test

if [ -d "$BUILD_DIR" ]; then
  sudo rm -rf "$BUILD_DIR"
fi
