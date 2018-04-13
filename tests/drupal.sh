#!/bin/sh

generate_config(){
  echo '---' > $CONFIG_FILE
  echo '' >> $CONFIG_FILE
  echo "project_type: drupal" >> $CONFIG_FILE
  echo "project_name: drupal" >> $CONFIG_FILE
  echo "volume_type: $VOLUME_TYPE" >> $CONFIG_FILE
}