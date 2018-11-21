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

# Absolute paths to playbook files directories on the guest.
def ansible_get_guest_playbook_dirs
  [
    File.join(fullpath_get_guest_user_home_dir, path_get_ce_vm_upstream_repo, 'ansible'),
    File.join(fullpath_get_guest_project_dir, 'ce-vm', 'ansible'),
    File.join(fullpath_get_guest_user_home_dir, path_get_ce_vm_custom_repo, 'ansible'),
    File.join(fullpath_get_guest_project_dir, 'ce-vm', 'local', 'ansible')
  ]
end

# Absolute paths to playbook files on the guest,
# filtered to ones that actually exist on the host.
def ansible_get_guest_active_playbooks(service)
  host_playbooks = build_file_list(ansible_get_host_playbook_dirs, ["#{service}.yml"])
  guest_playbooks = build_file_list(ansible_get_guest_playbook_dirs, ["#{service}.yml"])
  filter_file_list(host_playbooks, guest_playbooks)
end
