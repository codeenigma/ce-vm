#!/bin/sh

generate_config(){
  echo '---' > $CONFIG_FILE
  echo '' >> $CONFIG_FILE
  echo "project_type: symfony4" >> $CONFIG_FILE
  echo "project_name: symfony4" >> $CONFIG_FILE
  echo "volume_type: $VOLUME_TYPE" >> $CONFIG_FILE
  echo "webroot: public" >> $CONFIG_FILE
  echo "symfony_local_env: dev" >> $CONFIG_FILE
}
