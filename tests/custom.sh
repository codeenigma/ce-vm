#!/bin/sh

generate_config(){
  echo '---' > $CONFIG_FILE
  echo '' >> $CONFIG_FILE
  echo "project_type: custom" >> $CONFIG_FILE
  echo "project_name: custom" >> $CONFIG_FILE
  echo "volume_type: $VOLUME_TYPE" >> $CONFIG_FILE
  echo "webroot: www" >> $CONFIG_FILE
}