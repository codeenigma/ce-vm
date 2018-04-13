#!/bin/sh

generate_config(){
  echo '---' > $CONFIG_FILE
  echo '' >> $CONFIG_FILE
  echo "project_type: symfony3" >> $CONFIG_FILE
  echo "project_name: symfony3" >> $CONFIG_FILE
  echo "volume_type: $VOLUME_TYPE" >> $CONFIG_FILE
  echo "webroot: web" >> $CONFIG_FILE
  echo "symfony_local_env: local" >> $CONFIG_FILE
}