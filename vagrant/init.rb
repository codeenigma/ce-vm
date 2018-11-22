################################################################################
################ Build the actual Vagrant config.
################################################################################

################ Start iteration of config building.

# Process each services, and cascade down.
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  service_get_enabled_services.each do |service_name|
    config.vm.define service_name.to_s, primary: service_is_primary(service_name) do |container|
      init_container(container, service_name)
    end
  end
end

def init_container(container, service_name)
  # Add relevant Vagrant triggers.
  init__trigger(container, service_name)
  # Base config of the container.
  init__config(container, service_name)
  # Define providers.
  init__provider(container, service_name)
  # Define our provisioners,
  init__provision(container, service_name)
end

################ Vagrant triggers section.

# Add relevant Vagrant triggers.
def init__trigger(container, service_name)
  init__trigger_default(container, service_name)
  init__trigger_custom(container, service_name)
end

# Add ce-vm specific triggers.
def init__trigger_default(container, service_name)
  # This is not an actual Trigger, as we need this to act
  # before the Vagrant config is instanciated.
  docker_ensure_vagrant_id(service_name) if ARGV.include? 'up'
  # Mac OS X, we need interface aliases.
  return unless host_get_platform == 'mac_os'
  container.trigger.before :up do |trigger|
    host_trigger_ensure_lo_alias(trigger, service_name)
  end
end

# Add user defined triggers.
def init__trigger_custom(container, service_name)
  custom_triggers = config_get_service_item(service_name, "vagrant_triggers_#{host_get_platform}")
  return if custom_triggers.nil?
  custom_triggers.each do |type, events|
    events.each do |event, triggers|
      next unless %w[before after].include? type
      triggers.each do |custom_trigger|
        container.trigger.public_send(type, event.to_sym, custom_trigger)
      end
    end
  end
end

################ General configuration.

def init__config(container, service_name)
  init__config_base(container, service_name)
  init__config_ssh(container, service_name)
  init__config_hostsupdater(container, service_name)
end

# Base config.
def init__config_base(container, service_name)
  # Disable default "shared folder".
  container.vm.synced_folder '.', '/vagrant', disabled: true
  # Set hostname.
  container.vm.hostname = service_get_hostname(service_name)
end

# SSH config.
def init__config_ssh(container, service_name)
  host_platform = host_get_platform
  container.ssh.insert_key = false
  container.ssh.forward_agent = true
  # Only Mac needs port forwarding.
  return unless host_platform == 'mac_os'
  container.ssh.host = config_get_service_item(service_name, 'net_ip')
  container.ssh.port = 22
end

# HostsUpdater support.
def init__config_hostsupdater(container, service_name)
  return if config_get_service_item(service_name, 'skip_hosts_updater') == true
  container.vm.network :private_network, ip: config_get_service_item(service_name, 'net_ip')
  return if config_get_service_item(service_name, 'host_aliases').nil?
  container.hostsupdater.aliases = config_get_service_item(service_name, 'host_aliases')
end

################ Provider definition.

# Only a provider, Docker.
def init__provider(container, service_name)
  container.vm.provider 'docker' do |docker|
    docker.force_host_vm = false
    docker.has_ssh = true
    docker.image = config_get_service_item(service_name, 'docker_image')
    docker.name = service_get_container_name(service_name)
    docker.volumes = service_get_volumes(service_name)
    if service_get_port_forwarding(service_name)
      docker.ports = service_get_port_forwarding(service_name)
    end
    docker.create_args = service_get_docker_create_args(service_name)
    docker.cmd = ['/bin/sh', '/opt/ce-vm-start.sh', service_get_vagrant_user_uid(service_name).to_s, service_get_vagrant_group_gid(service_name).to_s]
  end
end

################ Provisioners definition.

def init__provision(container, service_name)
  init__provision_unison(container, service_name)
  init__provision_ansible(container, service_name)
  # Run startup scripts, last provisioning.
  container.vm.provision 'shell', run: 'always', inline: 'sudo run-parts /opt/run-parts'
end

# Manual sync data on initial start, for Unison.
def init__provision_unison(container, service_name)
  return unless service_uses_unison(service_name)
  unison = volume_get_mirror_volume['dest']
  data = volume_get_project_volume['dest']
  container.vm.provision 'shell', inline: "mkdir -p #{unison} -m 0777 && rsync -av --owner --perms --chmod=0777 --delete --exclude='.git' --exclude='.vagrant' '#{unison}/' '#{data}' && chown vagrant:vagrant #{data}"
end

def init__provision_ansible(container, service_name)
  ansible_get_guest_active_playbooks(service_name).each do |playbook|
    container.vm.provision 'ansible_local' do |ansible|
      ansible.playbook = playbook
      ansible.extra_vars = service_get_ansible_extra_vars(service_name)
      ansible.compatibility_mode = '2.0'
    end
  end
end
