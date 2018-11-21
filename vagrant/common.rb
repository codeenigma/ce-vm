################################################################################
################ Paths and volumes handling on host and guests.
################################################################################

################ Git values for ce-vm.

# Remote and branch. Normally passed by the project's Vagrantfile.
# Default to 3.x for backward compatibilty, as this feature
# was introduced in 4.x.
ENV['CE_VM_UPSTREAM_REPO'] = 'https://github.com/codeenigma/ce-vm.git' if ENV['CE_VM_UPSTREAM_REPO'].nil?
ENV['CE_VM_UPSTREAM_BRANCH'] = '3.x' if ENV['CE_VM_UPSTREAM_BRANCH'].nil?

################ Absolute paths definitions.

# Absolute paths to the project root on the host.
def fullpath_get_host_project_dir
  File.dirname(File.expand_path('..', ENV['PROJECT_VAGRANTFILE']))
end

# Absolute paths to the $HOME on the host.
def fullpath_get_host_user_home_dir
  File.expand_path('~')
end

# Absolute paths to the ce-vm local dir on the host.
def fullpath_get_host_ce_vm_homebase
  File.join(fullpath_get_host_user_home_dir, path_get_ce_vm_homebase)
end

# Absolute paths to the project root on the guest.
def fullpath_get_guest_project_dir
  '/vagrant'
end

# Absolute paths to the $HOME on the guest.
def fullpath_get_guest_user_home_dir
  '/home/vagrant'
end

# Absolute paths to the mirror of the project root on the guest.
# Used by Unison sync method.
def fullpath_get_guest_mirror_dir
  '/.ce-vm-mirror'
end

# Absolute paths to the ce-vm local dir on the guest.
def fullpath_get_guest_ce_vm_homebase
  File.join(fullpath_get_guest_user_home_dir, path_get_ce_vm_homebase)
end

################ Relative paths definitions.

# Path to the ce-vm local dir, relative to $HOME dir.
def path_get_ce_vm_homebase
  ce_vm_homebase = File.join('.CodeEnigma', 'ce-vm')
  unless ['2.x', '3.x', '4.x'].include? ENV['CE_VM_UPSTREAM_BRANCH']
    ce_vm_homebase = File.join(ce_vm_homebase, ENV['CE_VM_UPSTREAM_BRANCH'])
  end
  ce_vm_homebase
end

# Path to the ce-vm-upstream repo in the local dir, relative to $HOME dir.
def path_get_ce_vm_upstream_repo
  File.join(path_get_ce_vm_homebase, 'ce-vm-upstream')
end

# Path to the ce-vm-custom folder in the local dir, relative to $HOME dir.
def path_get_ce_vm_custom_repo
  File.join(path_get_ce_vm_homebase, 'ce-vm-custom')
end

################ Shared folders definitions.

# Project root.
def volume_get_project_volume
  { 'source' => fullpath_get_host_project_dir, 'dest' => fullpath_get_guest_project_dir }
end

# Project root's mirror.
def volume_get_mirror_volume
  { 'source' => fullpath_get_host_project_dir, 'dest' => fullpath_get_guest_mirror_dir }
end

# User's ce-vm local dir.
def volume_get_ce_vm_homebase_volume
  { 'source' => fullpath_get_host_ce_vm_homebase, 'dest' => fullpath_get_guest_ce_vm_homebase }
end
