#!/bin/sh

LAYERS="overlay volume"
DB_DUMP="replace-me-with-big-db.sql"

prepare_test(){
  COUNTER=10
  LINE=""
  for VOL_TYPE in $LAYERS; do
    COUNTER=$((COUNTER + 1))
    RUN_DIR="$BUILD_DIR/$VOL_TYPE"
    VM_DIR="$RUN_DIR/ce-vm"
    mkdir -p "$VM_DIR"
    cp "$VAGRANTFILE" "$VM_DIR/"
    cp "$CONFIG_YML" "$VM_DIR/"
    cp "$OWN_DIR/$DB_DUMP" "$RUN_DIR/"
    if [ "$VOL_TYPE" = "volume" ]; then
      echo "docker_extra_args_mac_os:" >> "$VM_DIR/config.yml"
      echo "  - '--volume'" >> "$VM_DIR/config.yml"
      echo "  - '/var'" >> "$VM_DIR/config.yml"
      echo "docker_extra_args_linux:" >> "$VM_DIR/config.yml"
      echo "  - '--volume'" >> "$VM_DIR/config.yml"
      echo "  - '/var'" >> "$VM_DIR/config.yml"
    fi
    echo "project_name: $VOL_TYPE" >> "$VM_DIR/config.yml"
    echo "" >> "$VM_DIR/config.yml" >> "$VM_DIR/config.yml"
    echo "net_base: 192.168.$COUNTER" >> "$VM_DIR/config.yml"
    cd "$VM_DIR"
    vagrant up mysql || exit 1
    LINE="$VOL_TYPE (restore),$VOL_TYPE (dump),$VOL_TYPE (drop),$LINE"
  done
  echo "$LINE" >> $RESULT_FILE
}

run_test(){
  LINE=""
  for VOL_TYPE in $LAYERS; do
    RUN_DIR="$BUILD_DIR/$VOL_TYPE"
    VM_DIR="$RUN_DIR/ce-vm"
    cd "$VM_DIR"
    start
    vagrant ssh mysql -c 'sudo mysql -e "create database mydb;"'
    vagrant ssh mysql -c "sudo mysql mydb < /vagrant/$DB_DUMP"
    end
    LINE="$RUN_TIME,$LINE"
    start
    vagrant ssh mysql -c "sudo mysqldump mydb > /dev/null"
    end
    LINE="$RUN_TIME,$LINE"
    start
    vagrant ssh -c 'sudo mysql -e "drop database mydb;"'
    end
    LINE="$RUN_TIME,$LINE"
  done
  echo "$LINE" >> $RESULT_FILE  
}

cleanup_test(){
  for VOL_TYPE in $LAYERS; do
    RUN_DIR="$BUILD_DIR/$VOL_TYPE"
    VM_DIR="$RUN_DIR/ce-vm"
    cd "$VM_DIR"
    vagrant destroy --force
  done
}