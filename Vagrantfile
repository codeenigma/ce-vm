# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2' unless defined? VAGRANTFILE_API_VERSION

# Prevent Vagrant from looking for VBox.
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'
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
def playbooks_find(host_dirs, run_dirs, filename)
  filtered = [];
  host_dirs.each.with_index do |h_dir, key|
    if(Dir.exists?(h_dir))
      if(File.exist?(File.join(h_dir, filename)))
        filtered.push(File.join(run_dirs[key], filename))
      end
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
  puts "Ensure Docker network #{name} exists on #{subnet}."
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
  puts "Ensure loopback interface alias exists for #{ip}."
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
if (ARGV.include? 'up') || (ARGV.include? 'halt')
  if(parsed_conf['ce_vm_upstream_auto_pull'] === true)
    puts "Ensure ce-vm is up-to-date."
    Vagrant::Util::Subprocess.execute("git", "-C", "#{_ce_upstream}", "fetch")
    Vagrant::Util::Subprocess.execute("git", "-C", "#{_ce_upstream}", "checkout", "#{ce_vm_upstream_branch}")
    Vagrant::Util::Subprocess.execute("git", "-C", "#{_ce_upstream}", "pull", "origin", "#{ce_vm_upstream_branch}")
  end
end
# Reload config on the matching branch.
Vagrant::Util::Subprocess.execute("git", "-C", "#{_ce_upstream}", "checkout", "#{ce_vm_upstream_branch}")
parsed_conf = conf_init({}, host_conf_files)

################ Common processing.
################################################################################

# Gather shared folders.
data_volume = {'source' => "#{host_project_dir}", 'dest' => "#{guest_project_dir}"}
host_ce_home = File.join("#{host_home_dir}", "#{ce_vm_local_home}")
guest_ce_home = File.join("#{guest_home_dir}", "#{ce_vm_local_home}")
home_ce_volume = {'source' => "#{host_ce_home}", 'dest' => "#{guest_ce_home}"}
#@todo, add a setting for "extra" shared volumes.
shared_volumes = [];

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
# This ugly pile of crap is going to DIE soon !!!
if (parsed_conf['docker_db_fwd_ports'] == "auto")
  parsed_conf['docker_db_fwd_ports'] = [];
  if(host_platform == "mac_os")
    parsed_conf['docker_db_fwd_ports'] = [
      "#{parsed_conf['net_db_ip']}:3306:3306",
      "#{parsed_conf['net_db_ip']}:8080:8080"
    ];
  end
end
if (parsed_conf['docker_app_fwd_ports'] == "auto")
  parsed_conf['docker_app_fwd_ports'] = [];
  if(host_platform == "mac_os")
    parsed_conf['docker_app_fwd_ports'] = [
      "#{parsed_conf['net_app_ip']}:80:80",
      "#{parsed_conf['net_app_ip']}:443:443",
      "#{parsed_conf['net_app_ip']}:5999:5999",
      "#{parsed_conf['net_app_ip']}:8000:8000"
    ];
  end
end
if (parsed_conf['docker_proto_fwd_ports'] == "auto")
  parsed_conf['docker_proto_fwd_ports'] = [];
  if(host_platform == "mac_os")
    parsed_conf['docker_proto_fwd_ports'] = [
      "#{parsed_conf['net_proto_ip']}:80:80"
    ];
  end
end
if (parsed_conf['docker_log_fwd_ports'] == "auto")
  parsed_conf['docker_log_fwd_ports'] = [];
  if(host_platform == "mac_os")
    parsed_conf['docker_log_fwd_ports'] = [
      "#{parsed_conf['net_log_ip']}:80:80"
    ];
  end
end

# On UP operation, create our network if needed.
if (ARGV.include? 'up')
  ensure_network(parsed_conf['net_gateway'], parsed_conf['net_subnet'], net_name)
  # Mac OS X, we need interface aliases.
  if(host_platform == "mac_os") && (ARGV.include? 'up')
    puts "Network configuration changes needed. This require administrative privileges."
  end
end

services = ['log', 'db', 'app']
ssh_ports = {'log' => 22205,'db' => 22203, 'app'=> 22202}
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  ################# Common config.
  config.ssh.insert_key = false
  config.ssh.forward_agent = true
  ################# END Common config.  

  # Iterate over services.
  services.each do |service|
    is_primary = false
    if (service === 'app')
      is_primary = true
    end
    name = "#{parsed_conf['project_name']}-#{service}"
    # SSH port forwarding.
    if (parsed_conf["docker_#{service}_ssh_port"] === "auto")
      parsed_conf["docker_#{service}_ssh_port"] = 22
      if(host_platform == "mac_os")
        parsed_conf["docker_#{service}_ssh_port"] = ssh_ports[service]
      end
    end
    # Privileged mode.
    if (parsed_conf["docker_#{service}_privileged"] == "auto")
      parsed_conf["docker_#{service}_privileged"] = false
      if(host_platform == "mac_os") && (service == "db")
        parsed_conf["docker_#{service}_privileged"] = true
      end
    end
    # Gather playbooks.
    run_playbooks = playbooks_find(host_playbook_dirs, guest_playbook_dirs, "#{service}.yml")
    # Mac OS X, we need interface aliases.
    if(host_platform == "mac_os") && (ARGV.include? 'up')
      ensure_lo_alias(parsed_conf["net_#{service}_ip"])
    end
    ################# Indivual container.
    config.vm.define "#{service}-vm", primary: is_primary do |container|
      # Base properties.
      container.ssh.host = parsed_conf["net_#{service}_ip"]
      container.ssh.port = parsed_conf["docker_#{service}_ssh_port"]
      container.vm.hostname = "#{name}"
      if(parsed_conf["docker_#{service}_ssh_port"] != 22)
        # Disable automatic port forwarding, we need a set one for docker.
        container.vm.network :forwarded_port, guest: 22, host: parsed_conf["docker_#{service}_ssh_port"], host_ip: parsed_conf["net_#{service}_ip"], id: 'ssh'
      end
      # Shared folders
      container.vm.synced_folder ".", "/vagrant", disabled: true
      volumes = []
      shared_volumes.each do |synced_folder|
        volumes.push("#{synced_folder['source']}/:#{synced_folder['dest']}:delegated")
      end
      dest = "#{data_volume['dest']}"
      source = "#{data_volume['source']}"
      if (parsed_conf['docker_mirror']) && (service === 'app')
        dest = "#{guest_mirror_dir}#{dest}"
        container.vm.provision "shell", inline: $mirror
      end
      volumes.push("#{source}/:#{dest}:delegated")
      # First ensure 'vagrant' ownership match.
      container.vm.provision "shell", inline: $vagrant_uid
      # Run actual playbooks.
      run_playbooks.each do |ansible_playbook_file|
        container.vm.provision 'ansible_local' do |ansible|
          ansible.playbook = ansible_playbook_file
          ansible.extra_vars = ansible_extra_vars
        end
      end
      # Run startup scripts.
      container.vm.provision "shell", run: "always", inline: "sudo run-parts /opt/run-parts"
      # Docker settings.
      container.vm.provider "docker" do |d|
        d.force_host_vm = false
        d.image = "pmce/ce-vm-#{service}:4.1.0"
        d.name = "#{name}"
        d.create_args = [
          "--network=#{net_name}",
          "--ip",
          "#{parsed_conf["net_#{service}_ip"]}",
          "-P",
          "--privileged=#{parsed_conf["docker_#{service}_privileged"]}", # Tomcat7 needs this on Mac.
          "--cap-add=SYS_PTRACE"
        ]
        d.ports = parsed_conf["docker_#{service}_fwd_ports"]
        d.has_ssh = true
        d.volumes = volumes
      end
    end
  end
  ################# END Individual container.
end
