# Retrieve the list of enabled services.
def service_get_enabled_services
  enabled = %w[log dashboard]
  config_get_item('services').each do |service_name|
    enabled.push(service_name) unless enabled.include? service_name
  end
  enabled
end

# Whether the service should be set as Primary vagrant machine.
def service_is_primary(service_name)
  return true if config_get_service_item(service_name, 'vagrant_is_primary') == true
  false
end

# Wether the service uses Unison as the sync mochanism.
def service_uses_unison(service_name)
  # Prevent unison use for crucial services.
  return false if %w[dashboard log].include? service_name
  return true if config_get_service_item(service_name, 'volume_type') == 'unison'
  false
end

# Get the generated container name.
def service_get_container_name(service_name)
  "#{config_get_service_item(service_name, 'project_name')}-#{service_name}"
end

# Get the generated hostname.
def service_get_hostname(service_name)
  "#{service_get_container_name(service_name)}.#{config_get_service_item(service_name, 'domain')}"
end

# An array of options to pass to docker run.
def service_get_docker_create_args(service_name)
  docker_args = [
    # "--network=#{docker_network_get_name}",
    # '--ip',
    # config_get_service_item(service_name, 'net_ip').to_s,
    '--volume',
    "ce-vm-cache:#{fullpath_get_guest_ce_vm_homebase}/cache",
    # '--volume',
    # '/var'
  ]
  extra_args = config_get_service_item(service_name, "docker_extra_args_#{host_get_platform}")
  return docker_args unless extra_args
  extra_args.each do |arg|
    docker_args.push(arg)
  end
  docker_args
end

# A hash of options to pass to Ansible.
def service_get_ansible_extra_vars(service_name)
  {
    config_files: config_get_guest_active_config_files(service_name),
    override_files: ansible_get_guest_active_override_files(service_name),
    project_dir: fullpath_get_guest_project_dir,
    host_project_dir: fullpath_get_host_project_dir,
    vm_dir: 'ce-vm',
    ce_vm_home: fullpath_get_guest_ce_vm_homebase,
    shared_cache_dir: "#{fullpath_get_guest_ce_vm_homebase}/cache",
    host_platform: host_get_platform,
    service_hostname: service_get_hostname(service_name),
    service_name: service_get_container_name(service_name)
  }
end

# Get the shared folders for a given service.
def service_get_volumes(service_name)
  shared = []
  if service_uses_unison(service_name)
    shared.push(volume_get_mirror_volume)
  else
    shared.push(volume_get_project_volume)
  end
  shared.push(volume_get_ce_vm_homebase_volume)
  volumes = []
  shared.each do |synced_folder|
    dest = synced_folder['dest'].to_s
    source = synced_folder['source'].to_s
    volumes.push("#{source}/:#{dest}:delegated")
  end
  volumes
end

# Get the port forwarding definition for a given service.
def service_get_port_forwarding(service_name)
  config_get_service_item(service_name, "net_fwd_ports_#{host_get_platform}")
end

# Grab user uid for vagrant user.
def service_get_vagrant_user_uid(service_name)
  uid = config_get_service_item(service_name, 'docker_vagrant_user_uid')
  return uid unless uid.nil?
  return 1000 unless host_get_platform == 'linux'
  Process.uid
end

# Grab group gid for vagrant user.
def service_get_vagrant_group_gid(service_name)
  gid = config_get_service_item(service_name, 'docker_vagrant_group_gid')
  return gid unless gid.nil?
  return 1000 unless host_get_platform == 'linux'
  Process.gid
end
