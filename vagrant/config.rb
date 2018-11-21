################################################################################
################ Configuration parsing and loading.
################################################################################

################ Paths definitions.

# Absolute paths to config files directories on the host.
def config_get_host_dirs
  [
    File.join(fullpath_get_host_user_home_dir, path_get_ce_vm_upstream_repo),
    File.join(fullpath_get_host_project_dir, 'ce-vm'),
    File.join(fullpath_get_host_user_home_dir, path_get_ce_vm_custom_repo),
    File.join(fullpath_get_host_project_dir, 'ce-vm', 'local')
  ]
end

# Absolute paths to config files directories on the guest.
def config_get_guest_dirs
  [
    File.join(fullpath_get_guest_user_home_dir, path_get_ce_vm_upstream_repo),
    File.join(fullpath_get_guest_project_dir, 'ce-vm'),
    File.join(fullpath_get_guest_user_home_dir, path_get_ce_vm_custom_repo),
    File.join(fullpath_get_guest_project_dir, 'ce-vm', 'local')
  ]
end

# Absolute paths to config files on the guest,
# filtered to ones that actually exist on the host.
def config_get_guest_active_config_files(service)
  host_files = build_file_list(config_get_host_dirs, ['config.yml', "service.#{service}.yml"])
  guest_files = build_file_list(config_get_guest_dirs, ['config.yml', "service.#{service}.yml"])
  filter_file_list(host_files, guest_files)
end

################ Configuration loading.

# Load the whole global config array.
def config_get_global_conf
  files = build_file_list(config_get_host_dirs, ['config.yml'])
  conf_init(files)
end

# Returns the value of a given key in global config.
# @param string
def config_get_item(item)
  conf = config_get_global_conf
  conf[item]
end

# Load the whole config array for a given service name.
# @param string
def config_get_service_conf(service)
  files = build_file_list(config_get_host_dirs, ['config.yml', "service.#{service}.yml"])
  conf_init(files)
end

# Returns the value of a given key for a given service name.
# @param string
# @param string
def config_get_service_item(service, item)
  conf = config_get_service_conf(service)
  conf[item]
end
