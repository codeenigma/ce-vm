#!/bin/sh

# Wrapper script. Forces docker calls to be 
# called by sudo.

sudo /usr/bin/docker $@
