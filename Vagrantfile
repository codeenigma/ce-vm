# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = '2' unless defined? VAGRANTFILE_API_VERSION


Vagrant.require_version ">= 1.9.1", "<= 1.9.8"

################ Helper functions. (credits to https://github.com/geerlingguy/drupal-vm)
################################################################################
# Utility function.
def walk(obj, &fn)
  if obj.is_a?(Array)
    obj.map { |value| walk(value, &fn) }
  elsif obj.is_a?(Hash)
    obj.each_pair { |key, value| obj[key] = walk(value, &fn) }
  else
    obj = yield(obj)
  end
end

# Replace jinja variables.
def parse(conf)
  walk(conf) do |value|
    while value.is_a?(String) && value.match(/{{ .* }}/)
      value = value.gsub(/{{ (.*?) }}/) { conf[Regexp.last_match(1)] }
    end
    value
  end
end

# Load configuration.
def conf_init(parsed_conf, conf_files)
  conf_files.each do |config_file|
    if File.exist?("#{config_file}")
      parsed_conf.merge!(YAML.load_file("#{config_file}"))
    end
  end
  parsed_conf = parse(parsed_conf)
end

# Gather potential playbook locations.
def playbooks_find(host_dirs, run_dirs)
  filtered = [];
  host_dirs.each.with_index do |h_dir, key|
    if(Dir.exists?(h_dir))
      filtered.push(run_dirs[key])
    end
  end
  return filtered
end

# Gather potential config files locations.
def config_files_find(host_files, run_files)
  filtered = [];
  host_files.each.with_index do |h_file, key|
    if(File.exists?(h_file))
      filtered.push(run_files[key])
    end
  end
  return filtered
end

################ Paths definitions.
################################################################################
# Absolute paths on the host machine.
host_project_dir = File.dirname(File.expand_path('..', ENV['PROJECT_VAGRANTFILE']))
host_home_dir = File.expand_path('~')
# Absolute paths on the guest machine.
guest_project_dir = '/vagrant'
guest_home_dir = '/home/vagrant'
guest_mirror_dir = '/.ce-vm-mirror'

# Relative paths.
vm_dir = File.basename(File.dirname(File.expand_path(ENV['PROJECT_VAGRANTFILE'])))
ansible_dir = 'ansible'
ce_local_home = '.CodeEnigma'
ce_vm_local_home = "#{ce_local_home}/ce-vm"
ce_vm_local_upstream_repo = "#{ce_vm_local_home}/ce-vm-upstream"
ce_vm_local_custom_repo = "#{ce_vm_local_home}/ce-vm-custom"

# Remote. Normally passed by the project's Vagrantfile.
# Default to 3.x for backward compatibilty, as this feature
# will actually be introduced in 4.x.
if ENV['CE_VM_UPSTREAM_REPO'].nil?
  ENV['CE_VM_UPSTREAM_REPO'] = 'https://github.com/codeenigma/ce-vm.git'
end
if ENV['CE_VM_UPSTREAM_BRANCH'].nil?
  ENV['CE_VM_UPSTREAM_BRANCH'] = '3.x'
end
ce_vm_upstream_repo = ENV['CE_VM_UPSTREAM_REPO']
ce_vm_upstream_branch = ENV['CE_VM_UPSTREAM_BRANCH']

################ Configuration loading.
################################################################################
# Order of config files and ansible playbooks does matter !
host_conf_files = [
  File.join("#{host_home_dir}", "#{ce_vm_local_upstream_repo}", 'config.yml'),
  File.join("#{host_project_dir}", "#{vm_dir}", 'config.yml'),
  File.join("#{host_home_dir}", "#{ce_vm_local_custom_repo}", 'config.yml'),
  File.join("#{host_project_dir}", "#{vm_dir}", 'local.config.yml'),
]

# Initial config.
require 'yaml'
parsed_conf = conf_init({}, host_conf_files)

guest_conf_files = [
  File.join("#{guest_home_dir}", "#{ce_vm_local_upstream_repo}", 'config.yml'),
  File.join("#{guest_project_dir}", "#{vm_dir}", 'config.yml'),
  File.join("#{guest_home_dir}", "#{ce_vm_local_custom_repo}", 'config.yml'),
  File.join("#{guest_project_dir}", "#{vm_dir}", 'local.config.yml'),
]

host_playbook_dirs = [
  File.join("#{host_project_dir}", "#{vm_dir}",  "#{ansible_dir}"),
  File.join("#{host_home_dir}", "#{ce_vm_local_custom_repo}", "#{ansible_dir}"),
  File.join("#{host_project_dir}", "#{vm_dir}", "local.#{ansible_dir}"),
]
if(parsed_conf['ce_vm_upstream'] === true)
  host_playbook_dirs.unshift(File.join("#{host_home_dir}", "#{ce_vm_local_upstream_repo}", "#{ansible_dir}"))
end

guest_playbook_dirs = [
  File.join("#{guest_project_dir}", "#{vm_dir}", "#{ansible_dir}"),
  File.join("#{guest_home_dir}", "#{ce_vm_local_custom_repo}", "#{ansible_dir}"),
  File.join("#{guest_project_dir}", "#{vm_dir}", "local.#{ansible_dir}"),
]
if(parsed_conf['ce_vm_upstream'] === true)
  guest_playbook_dirs.unshift(File.join("#{guest_home_dir}", "#{ce_vm_local_upstream_repo}", "#{ansible_dir}"))
end

################ Common processing.
################################################################################

# Update repo if needed, using triggers.
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.trigger.before :up do
    if(parsed_conf['ce_vm_upstream_auto_pull'] === true)
      _ce_upstream = File.join("#{host_home_dir}", "#{ce_vm_local_upstream_repo}")
      run "git -C #{_ce_upstream} fetch"
      run "git -C #{_ce_upstream} checkout #{ce_vm_upstream_branch}" 
      run "git -C #{_ce_upstream} pull origin #{ce_vm_upstream_branch}"
      # Reload config.
      parsed_conf = conf_init({}, host_conf_files)
      run_playbook_dirs = playbooks_find(host_playbook_dirs, guest_playbook_dirs)
    end
  end
end

# VM names.
vapp = "#{parsed_conf['project_name']}"
vdb = "#{parsed_conf['project_name']}-db"

# Gather shared folders.
data_volume = {'source' => "#{host_project_dir}", 'dest' => "#{guest_project_dir}"}
host_ce_home = File.join("#{host_home_dir}", "#{ce_vm_local_home}")
guest_ce_home = File.join("#{guest_home_dir}", "#{ce_vm_local_home}")
home_ce_volume = {'source' => "#{host_ce_home}", 'dest' => "#{guest_ce_home}"}
#@todo, add a setting for "extra" shared volumes.
shared_volumes = [];

# Gather playbooks.
run_playbook_dirs = playbooks_find(host_playbook_dirs, guest_playbook_dirs)
# Gather config files to pass to Ansible.
run_config_files = config_files_find(host_conf_files, guest_conf_files)

# Pass host platform to ansible.
host_platform="windows"
if (RUBY_PLATFORM =~ /darwin/)
  host_platform="mac_os"
end
if (RUBY_PLATFORM =~ /linux/)
  host_platform="linux"
end
# Configuration to pass to Ansible.
ansible_extra_vars = {
  config_files: "#{run_config_files}",
  project_dir: "#{guest_project_dir}",
  vm_dir: "#{vm_dir}",
  ce_vm_home: "#{guest_ce_home}",
  shared_cache_dir: "#{guest_ce_home}/cache/#{parsed_conf['vagrant_provider']}",
  host_platform: "#{host_platform}",
  vagrant_provider: "#{parsed_conf['vagrant_provider']}"
}

# Call provider specific include.
eval File.read File.join("#{host_home_dir}", "#{ce_vm_local_upstream_repo}", "Vagrantfile.#{parsed_conf['vagrant_provider']}")
