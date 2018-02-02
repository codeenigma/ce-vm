# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.9.1", "<= 2.0.1"

VAGRANTFILE_API_VERSION = '2' unless defined? VAGRANTFILE_API_VERSION

# We need the database to be always setup first,
# so can't process provisioning in parallel.
ENV['VAGRANT_NO_PARALLEL'] = 'yes'

require 'yaml'

################ Helper functions.
################################################################################
# Utility function (taken from https://github.com/geerlingguy/drupal-vm).
def walk(obj, &fn)
  if obj.is_a?(Array)
    obj.map { |value| walk(value, &fn) }
  elsif obj.is_a?(Hash)
    obj.each_pair { |key, value| obj[key] = walk(value, &fn) }
  else
    obj = yield(obj)
  end
end

# Replace jinja variables (taken from https://github.com/geerlingguy/drupal-vm).
def parse(conf)
  walk(conf) do |value|
    while value.is_a?(String) && value.match(/{{ .* }}/)
      value = value.gsub(/{{ (.*?) }}/) { conf[Regexp.last_match(1)] }
    end
    value
  end
end

# Load configuration (taken from https://github.com/geerlingguy/drupal-vm ?).
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

# Create/Ensure Docker Network exists.
def ensure_network(gateway, subnet, name)
  existing_net = Vagrant::Util::Subprocess.new('docker', 'network', 'inspect', '--format={{range .IPAM.Config}}{{.Subnet}}{{end}}',  "#{name}").execute.stdout
  existing_gw = Vagrant::Util::Subprocess.new('docker', 'network', 'inspect', '--format={{range .IPAM.Config}}{{.Gateway}}{{end}}',  "#{name}").execute.stdout
  existing_net.strip!
  existing_gw.strip!
  if (subnet != existing_net || gateway != existing_gw)
    unless (existing_net.empty?)
      Vagrant::Util::Subprocess.new('docker', 'network', 'rm', "#{name}").execute
    end
    Vagrant::Util::Subprocess.new('docker', 'network', 'create', "--subnet=#{subnet}", "--gateway=#{gateway}", "#{name}").execute
  end
end

# Create/Ensure loopback interface exists (Mac OS X).
def ensure_lo_alias(ip)
  Vagrant::Util::Subprocess.execute("sudo", "ifconfig", "lo0", "alias", "#{ip}/32")
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
# was introduced in 4.x.
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

# Initial config. This is reloaded later.
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

################ Branch setup.
################################################################################
# Update repo if needed, and ensure we're on the right branch.
_ce_upstream = File.join("#{host_home_dir}", "#{ce_vm_local_upstream_repo}")
if(parsed_conf['ce_vm_upstream_auto_pull'] === true)
  Vagrant::Util::Subprocess.execute("git", "-C", "#{_ce_upstream}", "fetch")
  Vagrant::Util::Subprocess.execute("git", "-C", "#{_ce_upstream}", "checkout", "#{ce_vm_upstream_branch}")
  Vagrant::Util::Subprocess.execute("git", "-C", "#{_ce_upstream}", "pull", "origin", "#{ce_vm_upstream_branch}")
end
# Reload config on the matching branch.
Vagrant::Util::Subprocess.execute("git", "-C", "#{_ce_upstream}", "checkout", "#{ce_vm_upstream_branch}")
parsed_conf = conf_init({}, host_conf_files)
run_playbook_dirs = playbooks_find(host_playbook_dirs, guest_playbook_dirs)


################ Common processing.
################################################################################

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
  shared_cache_dir: "#{guest_ce_home}/cache",
  host_platform: "#{host_platform}",
}

net_name = "codeenigma-cevm"

shared_volumes.push(home_ce_volume)

# Vagrant uid change.
$vagrant_uid = <<SCRIPT
OWN_CHANGED=0
if [ "$(id -u vagrant)" != "#{parsed_conf['docker_vagrant_user_uid']}" ]; then
  usermod -u #{parsed_conf['docker_vagrant_user_uid']} vagrant
  echo "User ID changed to #{parsed_conf['docker_vagrant_user_uid']}."
  chown -R vagrant:www-data /vagrant
  echo "Changed ownership of shared files accordingly."
  OWN_CHANGED=1
fi
if [ "$(id -g vagrant)" != "#{parsed_conf['docker_vagrant_group_gid']}" ]; then
  groupmod -g #{parsed_conf['docker_vagrant_group_gid']} vagrant
  OWN_CHANGED=1
fi
if [ $OWN_CHANGED -eq 1 ]; then
  echo "Interrupting the provisioning for the ownership changes to take effect."
  echo "This will trigger a Vagrant error below, do not panic this is normal."
  echo "Please manually relaunch the process using 'vagrant up'."
  exit 1
fi

SCRIPT

# Initial data sync.
$mirror = <<SCRIPT
echo "Initial data mirror synchronisation."
if [ ! -d "#{guest_project_dir}" ]; then
  mkdir "#{guest_project_dir}"
fi
rsync -av --chown=vagrant:vagrant --chmod=0777 --exclude=".git" --exclude=".vagrant" --exclude=".unison.*" "#{guest_mirror_dir}#{guest_project_dir}/#{vm_dir}" "#{guest_project_dir}/"
SCRIPT

# Platform-specific adjustments.
if (parsed_conf['docker_app_privileged'] == "auto")
  parsed_conf['docker_app_privileged'] = "false"
end
if (parsed_conf['docker_db_privileged'] == "auto")
  parsed_conf['docker_db_privileged'] = "true"
end
if (parsed_conf['docker_db_ssh_port'] == "auto")
  parsed_conf['docker_db_ssh_port'] = 22
  if(host_platform == "mac_os")
    parsed_conf['docker_db_ssh_port'] = 22203
  end
end
if (parsed_conf['docker_app_ssh_port'] == "auto")
  parsed_conf['docker_app_ssh_port'] = 22
  if(host_platform == "mac_os")
    parsed_conf['docker_app_ssh_port'] = 22202
  end
end
if (parsed_conf['docker_db_fwd_ports'] == "auto")
  parsed_conf['docker_db_fwd_ports'] = [];
  if(host_platform == "mac_os")
    parsed_conf['docker_db_fwd_ports'] = [
      "#{parsed_conf['net_db_ip']}:#{parsed_conf['docker_db_ssh_port']}:22",
      "#{parsed_conf['net_db_ip']}:3306:3306",
      "#{parsed_conf['net_db_ip']}:8080:8080"
    ];
  end
end
if (parsed_conf['docker_app_fwd_ports'] == "auto")
  parsed_conf['docker_app_fwd_ports'] = [];
  if(host_platform == "mac_os")
    parsed_conf['docker_app_fwd_ports'] = [
      "#{parsed_conf['net_app_ip']}:#{parsed_conf['docker_app_ssh_port']}:22",
      "#{parsed_conf['net_app_ip']}:80:80",
      "#{parsed_conf['net_app_ip']}:443:443",
      "#{parsed_conf['net_app_ip']}:5999:5999",
      "#{parsed_conf['net_app_ip']}:8000:8000"
    ];
  end
end

# On UP operation, create our network if needed.
if (ARGV.include? 'up')
  ensure_network(parsed_conf['net_gateway'], parsed_conf['net_subnet'], net_name)
  # Mac OS X, we need interface aliases.
  if(host_platform == "mac_os") && (ARGV.include? 'up')
    puts "Network configuration changes needed. This require administrative privileges."
    ensure_lo_alias(parsed_conf['net_db_ip'])
    ensure_lo_alias(parsed_conf['net_app_ip'])
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  ################# Common config.
  config.ssh.insert_key = false
  config.ssh.forward_agent = true
  ################# END Common config.  

  ################# Database VM.
  config.vm.define "db-vm" do |db|
    # Base properties.
    db.ssh.host = parsed_conf['net_db_ip']
    db.ssh.port = parsed_conf['docker_db_ssh_port']
    db.vm.hostname = "#{vdb}"
    if(parsed_conf['docker_db_ssh_port'] != 22)
      # Disable default port forwarding, as we define a custom one.
      db.vm.network :forwarded_port, guest: 22, host: parsed_conf['docker_db_ssh_port'], id: 'ssh'
    end
    # Shared folders
    db.vm.synced_folder ".", "/vagrant", disabled: true
    db_volumes = []
    shared_volumes.each do |synced_folder|
      db_volumes.push("#{synced_folder['source']}/:#{synced_folder['dest']}")
    end
    db_volumes.push("#{data_volume['source']}/:#{data_volume['dest']}")
    # First ensure 'vagrant' ownership match.
    db.vm.provision "shell", inline: $vagrant_uid
    # Run actual playbooks.
    run_playbook_dirs.each do |ansible_folder|
      db.vm.provision 'ansible_local' do |ansible|
        ansible.playbook = "#{ansible_folder}/db.yml"
        ansible.extra_vars = ansible_extra_vars
      end
    end
    # Run startup scripts.
    db.vm.provision "shell", run: "always", inline: "sudo run-parts /opt/run-parts"
    # Docker settings.
    db.vm.provider "docker" do |d|
      d.force_host_vm = false
      d.image = "pmce/jessie64:4.0.0"
      d.name = "#{vdb}"
      d.create_args = [
        "--network=#{net_name}",
        "--ip",
        "#{parsed_conf['net_db_ip']}",
        "-P",
        "--privileged=#{parsed_conf['docker_db_privileged']}", # Tomcat7 needs this on Mac.
      ]
      d.ports = parsed_conf['docker_db_fwd_ports']
      d.has_ssh = true
      d.volumes = db_volumes
    end
  end
  ################# END Database VM.

  ################# App VM.
  config.vm.define "app-vm", primary: true do |app|
    # Base properties.
    app.ssh.host = parsed_conf['net_app_ip']
    app.ssh.port = parsed_conf['docker_app_ssh_port']
    app.vm.hostname = "#{vapp}"
    if(parsed_conf['docker_app_ssh_port'] != 22)
      # Disable default port forwarding, as we define a custom one.
      app.vm.network :forwarded_port, guest: 22, host: parsed_conf['docker_app_ssh_port'], id: 'ssh'
    end
    # Shared folders
    app.vm.synced_folder ".", "/vagrant", disabled: true
    app_volumes = []
    shared_volumes.each do |synced_folder|
      app_volumes.push("#{synced_folder['source']}/:#{synced_folder['dest']}:delegated")
    end
    dest = "#{data_volume['dest']}"
    source = "#{data_volume['source']}"
    if(parsed_conf['docker_mirror'])
      dest = "#{guest_mirror_dir}#{dest}"
    end
    app_volumes.push("#{source}/:#{dest}")
    if(parsed_conf['docker_mirror'])
      app.vm.provision "shell", inline: $mirror
    end
    # First ensure 'vagrant' ownership match.
    app.vm.provision "shell", inline: $vagrant_uid
    # Run actual playbooks.
    run_playbook_dirs.each do |ansible_folder|
        app.vm.provision 'ansible_local' do |ansible|
          ansible.playbook = "#{ansible_folder}/app.yml"
          ansible.extra_vars = ansible_extra_vars
        end
    end
    # Run startup scripts.
    app.vm.provision "shell", run: "always", inline: "sudo run-parts /opt/run-parts"
    # Docker settings.
    app.vm.provider "docker" do |d|
      d.force_host_vm = false
      d.image = "pmce/jessie64:4.0.0"
      d.name = "#{vapp}"
      d.create_args = [
        "--network=#{net_name}",
        "--ip",
        "#{parsed_conf['net_app_ip']}",
        "-P",
        "--privileged=#{parsed_conf['docker_app_privileged']}",
      ]
      d.ports = parsed_conf['docker_app_fwd_ports']
      d.has_ssh = true
      d.volumes = app_volumes
    end
  end
  ################# END App VM.

end