################################################################################
################ Ansible playbook management.
################################################################################

################ Paths definitions.

# Absolute paths to playbook files directories on the host.
def ansible_get_host_playbook_dirs
  [
    File.join(fullpath_get_host_user_home_dir, path_get_ce_vm_upstream_repo, 'ansible'),
    File.join(fullpath_get_host_project_dir, 'ce-vm', 'ansible'),
    File.join(fullpath_get_host_user_home_dir, path_get_ce_vm_custom_repo, 'ansible'),
    File.join(fullpath_get_host_project_dir, 'ce-vm', 'local', 'ansible')
  ]
end

# Absolute paths to playbook overrides directories on the host.
def ansible_get_host_override_dirs
  overrides = []
  ansible_get_host_playbook_dirs.each do |dir|
    overrides.push(File.join(dir, 'override'))
  end
  overrides
end

# Absolute paths to playbook files directories on the guest.
def ansible_get_guest_playbook_dirs
  [
    File.join(fullpath_get_guest_user_home_dir, path_get_ce_vm_upstream_repo, 'ansible'),
    File.join(fullpath_get_guest_project_dir, 'ce-vm', 'ansible'),
    File.join(fullpath_get_guest_user_home_dir, path_get_ce_vm_custom_repo, 'ansible'),
    File.join(fullpath_get_guest_project_dir, 'ce-vm', 'local', 'ansible')
  ]
end

# Absolute paths to playbook overrides directories on the guest.
def ansible_get_guest_override_dirs
  overrides = []
  ansible_get_guest_playbook_dirs.each do |dir|
    overrides.push(File.join(dir, 'override'))
  end
  overrides
end

# Absolute paths to playbook files on the guest,
# filtered to ones that actually exist on the host.
def ansible_get_guest_active_playbooks(service)
  playbook_names = []
  base_playbook_name = config_get_service_item(service, 'playbook_from')
  playbook_names.push("#{base_playbook_name}.yml") unless base_playbook_name.nil?
  playbook_names.push("#{service}.yml")
  host_playbooks = build_file_list(ansible_get_host_playbook_dirs, playbook_names)
  guest_playbooks = build_file_list(ansible_get_guest_playbook_dirs, playbook_names)
  filter_file_list(host_playbooks, guest_playbooks)
end

# Hash of absolute sources and destinations for override files on the guest.
def ansible_get_guest_active_override_files(service)
  host_overrides = build_file_list(ansible_get_host_override_dirs, [service])
  guest_overrides = build_file_list(ansible_get_guest_override_dirs, [service])
  overrides = []
  host_overrides.each.with_index do |dir, index|
    Dir.glob("#{dir}/**/*", File::FNM_DOTMATCH).each do |file|
      # Looks funny, eh ?
      next unless File.file? file
      file.sub!(dir, '')
      entry = {
        'src' => "#{guest_overrides[index]}#{file}",
        'dest' => file.to_s
      }
      overrides.push(entry)
    end
  end
  overrides
end
