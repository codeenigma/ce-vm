#!/bin/sh

prepare_test(){
  COUNTER=10
  LINE=""
  for VOL_TYPE in $VOL_TYPES; do
    COUNTER=$((COUNTER + 1))
    RUN_DIR="$BUILD_DIR/$VOL_TYPE"
    VM_DIR="$RUN_DIR/ce-vm"
    mkdir -p "$VM_DIR"
    cp "$VAGRANTFILE" "$VM_DIR/"
    cp "$CONFIG_YML" "$VM_DIR/"
    echo "volume_type: $VOL_TYPE" >> "$VM_DIR/config.yml"
    echo "" >> "$VM_DIR/config.yml"
    echo "project_name: $VOL_TYPE" >> "$VM_DIR/config.yml"
    echo "" >> "$VM_DIR/config.yml" >> "$VM_DIR/config.yml"
    echo "net_base: 192.168.$COUNTER" >> "$VM_DIR/config.yml"
    cd "$VM_DIR"
    vagrant up dashboard || exit 1
    vagrant up cli || exit 1
    LINE="$VOL_TYPE (write), $VOL_TYPE (read),$VOL_TYPE (delete),$LINE"
  done
  echo "$LINE" >> $RESULT_FILE
}

run_test(){
  LINE=""
  for VOL_TYPE in $VOL_TYPES; do
    RUN_DIR="$BUILD_DIR/$VOL_TYPE"
    VM_DIR="$RUN_DIR/ce-vm"
    cd "$VM_DIR"
    start
    vagrant ssh -c "cd /vagrant &&  composer create-project symfony/website-skeleton my-project"
    end
    LINE="$RUN_TIME,$LINE"
    start
    vagrant ssh -c "sudo cp -a /vagrant/my-project /tmp/"
    end
    LINE="$RUN_TIME,$LINE"
    start
    vagrant ssh -c "sudo rm -rf /vagrant/my-project"
    end
    LINE="$RUN_TIME,$LINE"
  done
  echo "$LINE" >> $RESULT_FILE  
}

cleanup_test(){
  for VOL_TYPE in $VOL_TYPES; do
    RUN_DIR="$BUILD_DIR/$VOL_TYPE"
    VM_DIR="$RUN_DIR/ce-vm"
    cd "$VM_DIR"
    vagrant destroy --force
  done
}