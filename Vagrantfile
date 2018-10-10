# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2' unless defined? VAGRANTFILE_API_VERSION

# Enforce to use a recent vagrant version to use triggers
Vagrant.require_version '>= 2.1.0'

# Prevent Vagrant from looking for VBox.
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'
# We need to control order,
# so can't process provisioning in parallel.
ENV['VAGRANT_NO_PARALLEL'] = 'yes'
# Ensure this is not nil.
ENV['VAGRANT_DOTFILE_PATH'] = '.vagrant' if ENV['VAGRANT_DOTFILE_PATH'].nil?

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
def conf_init(conf_files)
  conf = {}
  conf_files.each do |config_file|
    if File.exist?(config_file)
      conf.merge!(YAML.load_file(config_file))
    end
  end
  conf = parse(conf)
  return conf
end

# Build a list of files.
def build_file_list(dirs, filenames)
  files = []
  filenames.each do |filename|
    dirs.each do |dir|
      files.push(File.join(dir, filename))
    end
  end
  return files
end

# Filter existing files for guest.
def filter_file_list(host_files, run_files)
  filtered = []
  host_files.each.with_index do |h_file, key|
    if(File.exist?(h_file))
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

# Forces the 'link' from Vagrant to Docker, as it can get lost in case of failure.
# This can only work because we have 'set' names, and container names are unique.
def ensure_docker_id(service, name)
  docker_id = Vagrant::Util::Subprocess.execute("docker", "inspect", "--format={{.Id}}", name).stdout.strip!;
  if docker_id.empty?
    # Nothing to do.
    return
  end
  # Check if we have a vagrant subfolder.
  docker_id_file = File.join(ENV["VAGRANT_DOTFILE_PATH"], 'machines', service, 'docker', 'id')
  unless File.exists?(docker_id_file)
    # Something is totally borked.
    raise Vagrant::Errors::VagrantError.new, "Missing internal Vagrant marker file #{docker_id_file} but a container with name #{name} was found. \n This should not happen under normal operations and indicates the container failed to start properly or was not stopped properly. !\nThe safest is to delete the container with `docker rm #{docker_id}` and start from fresh.\n If you feeling adventurous and you know what you are doing, you can try to `touch #{docker_id_file}` and `vagrant up` again."
  end
  stored_id = File.read(docker_id_file)
  # Nothing to do, everything matches.
  if "#{stored_id}" === "#{docker_id}"
    return;
  end
  # Connection somehow got lost. Try to resume.
  puts "Warning: the container #{name} exists, but is not present in Vagrant machine index. \n Attempting to re-map them, but it might be corrupted.\n You might need to `vagrant destroy #{service}’ and recreate it with a `vagrant up` again in case of issues." 
  File.write(docker_id_file, docker_id)
end

# Ensure plugins are installed (updated Aug 31, 2018: https://stackoverflow.com/questions/19492738/demand-a-vagrant-plugin-within-the-vagrantfile/28801317#28801317).
def ensure_plugins(plugins)
  logger = Vagrant::UI::Colored.new
  plugins_to_install = plugins.select { |plugin| not Vagrant.has_plugin? plugin }
  if not plugins_to_install.empty?
    logger.warn("Installing plugins: #{plugins_to_install.join(' ')}")
    if system "vagrant plugin install #{plugins_to_install.join(' ')}"
      # Exit after installation, to avoid https://github.com/hashicorp/vagrant/issues/2435.
      logger.warn("Plugins installed. Please re-run the initial command.")
    else
      logger.error("Installation of one or more plugins has failed. sudo must be used to install plugins. Aborting.")
    end
    exit
  end
end

################ Paths definitions.
################################################################################

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
ce_vm_local_home = File.join(ce_local_home, 'ce-vm')
unless (['2.x', '3.x', '4.x'].include? ce_vm_upstream_branch)
  ce_vm_local_home = File.join(ce_vm_local_home, ce_vm_upstream_branch)
end
ce_vm_local_upstream_repo = File.join(ce_vm_local_home, 'ce-vm-upstream')
ce_vm_local_custom_repo = File.join(ce_vm_local_home, 'ce-vm-custom')

################ Configuration loading.
################################################################################
# Order of config files and ansible playbooks does matter !
host_conf_dirs = [
  File.join(host_home_dir, ce_vm_local_upstream_repo),
  File.join(host_project_dir, vm_dir),
  File.join(host_home_dir, ce_vm_local_custom_repo),
  File.join(host_project_dir, vm_dir, 'local'),
]
guest_conf_dirs = [
  File.join(guest_home_dir, ce_vm_local_upstream_repo),
  File.join(guest_project_dir, vm_dir),
  File.join(guest_home_dir, ce_vm_local_custom_repo),
  File.join(guest_project_dir, vm_dir, 'local'),
]
host_playbook_dirs = [
  File.join(host_home_dir, ce_vm_local_upstream_repo, ansible_dir),
  File.join(host_project_dir, vm_dir,  ansible_dir),
  File.join(host_home_dir, ce_vm_local_custom_repo, ansible_dir),
  File.join(host_project_dir, vm_dir, 'local', ansible_dir),
]
guest_playbook_dirs = [
  File.join(guest_home_dir, ce_vm_local_upstream_repo, ansible_dir),
  File.join(guest_project_dir, vm_dir, ansible_dir),
  File.join(guest_home_dir, ce_vm_local_custom_repo, ansible_dir),
  File.join(guest_project_dir, vm_dir, 'local', ansible_dir),
]
# Initial config. This is reloaded later.
host_conf_files = build_file_list(host_conf_dirs, ['config.yml'])
parsed_conf = conf_init(host_conf_files)

################ Initial setup.
################################################################################
# Ensure we have the needed plugins.
if (ARGV.include? 'up')
  plugins = ['vagrant-hostsupdater']
  ensure_plugins(plugins)
end
# Update repo if needed, and ensure we're on the right branch.
_ce_upstream = File.join("#{host_home_dir}", "#{ce_vm_local_upstream_repo}")
if (ARGV.include? 'up') || (ARGV.include? 'halt')
  if(parsed_conf['ce_vm_auto_update'] === true)
    puts "Ensure ce-vm is up-to-date."
    Vagrant::Util::Subprocess.execute("git", "-C", "#{_ce_upstream}", "fetch")
    Vagrant::Util::Subprocess.execute("git", "-C", "#{_ce_upstream}", "checkout", "#{ce_vm_upstream_branch}")
    Vagrant::Util::Subprocess.execute("git", "-C", "#{_ce_upstream}", "pull", "origin", "#{ce_vm_upstream_branch}")
  end
end
# Reload config on the matching branch.
Vagrant::Util::Subprocess.execute("git", "-C", "#{_ce_upstream}", "checkout", "#{ce_vm_upstream_branch}")
parsed_conf = conf_init(host_conf_files)
net_name = "ce-vm-#{parsed_conf['net_subnet']}"

################ Common processing.
################################################################################

# Gather shared folders.
data_volume = {'source' => "#{host_project_dir}", 'dest' => "#{guest_project_dir}"}
host_ce_home = File.join("#{host_home_dir}", "#{ce_vm_local_home}")
guest_ce_home = File.join("#{guest_home_dir}", "#{ce_vm_local_home}")
home_ce_volume = {'source' => "#{host_ce_home}", 'dest' => "#{guest_ce_home}"}
#@todo, add a setting for "extra" shared volumes.
shared_volumes = [
  home_ce_volume,
  data_volume,
];

# Pass host platform to ansible.
host_platform="windows"
if (RUBY_PLATFORM =~ /darwin/)
  host_platform="mac_os"
end
if (RUBY_PLATFORM =~ /linux/)
  host_platform="linux"
end

# On UP operation, create our network if needed.
if (ARGV.include? 'up')
  ensure_network(parsed_conf['net_gateway'], parsed_conf['net_subnet'], net_name)
  # Mac OS X, we need interface aliases.
  if(host_platform == "mac_os") && (ARGV.include? 'up')
    puts "Network configuration changes needed. This require administrative privileges."
  end
end

# Gather enabled services, and pull images if needed.
services = ['log', 'dashboard']
parsed_conf['services'].each do |enabled|
  unless(['log', 'dashboard'].include? enabled)
    services.push(enabled)
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  ################# Common config.
  config.ssh.insert_key = false
  config.ssh.forward_agent = true
  ################# END Common config.

  # Iterate over services.
  services.each do |service|
    # Reload config for the given service.
    host_service_conf_files = build_file_list(host_conf_dirs, ['config.yml', "service.#{service}.yml"])
    guest_service_conf_files = build_file_list(guest_conf_dirs, ['config.yml', "service.#{service}.yml"])
    run_service_conf_files = filter_file_list(host_service_conf_files, guest_service_conf_files)
    service_conf = conf_init(host_service_conf_files)
    # Gather existing playbooks.
    host_service_playbooks = build_file_list(host_playbook_dirs, ["#{service}.yml"])
    guest_service_playbooks = build_file_list(guest_playbook_dirs, ["#{service}.yml"])
    run_service_playbooks = filter_file_list(host_service_playbooks, guest_service_playbooks)
    # Mac OS X, we need interface aliases.
    if(host_platform == "mac_os") && (ARGV.include? 'up')
      ensure_lo_alias(service_conf["net_ip"])
    end
    # @TODO this could be an option.
    is_primary = false
    if (service === 'cli')
      is_primary = true
    end
    # Grab user uid/gid for vagrant user.
    if service_conf['docker_vagrant_user_uid'].nil?
      service_conf['docker_vagrant_user_uid'] = 1000
      if (host_platform === 'linux')
        service_conf['docker_vagrant_user_uid'] = Process.uid
      end
    end

    if service_conf['docker_vagrant_group_gid'].nil?
      service_conf['docker_vagrant_group_gid'] = 1000
      if (host_platform === 'linux')
        service_conf['docker_vagrant_group_gid'] = Process.gid
      end
    end

    name = "#{service_conf['project_name']}-#{service}"
    # Check if container already exists, by grabbing it by name.
    if (ARGV.include? 'up')
      ensure_docker_id(service, name)
    end
    ################# Indivual container.
    config.vm.define "#{service}", primary: is_primary do |container|
      # Only Mac needs port forwarding.
      unless(host_platform == "mac_os")
        container.ssh.host = service_conf["net_ip"]
        container.ssh.port = 22
      end
      # HostUpdater support.
      container.vm.hostname = "#{name}.#{service_conf['domain']}"
      container.vm.network :private_network, ip: service_conf["net_ip"]
      unless service_conf['host_aliases'].nil?
        container.hostsupdater.aliases = service_conf['host_aliases']
      end
      # Shared folders
      container.vm.synced_folder ".", "/vagrant", disabled: true
      # Always use native fs for base services.
      if (['dashboard', 'log'].include? service)
       service_conf['volume_type'] = 'native'
      end
      volumes = []
      shared_volumes.each.with_index do |synced_folder|
        dest = "#{synced_folder['dest']}"
        source = "#{synced_folder['source']}"
        if (service_conf['volume_type'] === 'sshfs')
          container.vm.provision "shell", run: "always", inline: "sudo mkdir -p #{dest} && sudo chown vagrant:vagrant #{dest} && mountpoint -q #{dest} || sudo sshfs -o kernel_cache -o cache=yes -o compression=yes -o allow_other -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o IdentityFile=/home/vagrant/.ssh/id_rsa vagrant@#{parsed_conf['project_name']}-dashboard:#{dest} #{dest}"
        else
          if (service_conf['volume_type'] === 'unison') && (dest === data_volume['dest'])
            original_dest = dest
            dest = "#{guest_mirror_dir}#{dest}"
            container.vm.provision "shell", inline: "mkdir -p #{original_dest} -m 0777 && rsync -av --owner --perms --chmod=0777 --delete --exclude='.git' --exclude='.vagrant' '#{dest}/' '#{original_dest}' && chown vagrant:vagrant #{original_dest}"
          end
          volumes.push("#{source}/:#{dest}:delegated")
        end
      end
      # Run actual playbooks.
      run_service_playbooks.each do |ansible_playbook_file|
        container.vm.provision 'ansible_local' do |ansible|
          # Configuration to pass to Ansible.
          ansible_extra_vars = {
            config_files: "#{run_service_conf_files}",
            project_dir: "#{guest_project_dir}",
            host_project_dir: "#{host_project_dir}",
            vm_dir: "#{vm_dir}",
            ce_vm_home: "#{guest_ce_home}",
            shared_cache_dir: "#{guest_ce_home}/cache",
            host_platform: "#{host_platform}",
            service_hostname: "#{container.vm.hostname}",
            service_name: "#{name}",
          }
          ansible.playbook = ansible_playbook_file
          ansible.extra_vars = ansible_extra_vars
          #ansible.compatibility_mode = '2.0'
        end
      end
      # Run startup scripts, post provisioning.
      container.vm.provision "shell", run: "always", inline: "sudo run-parts /opt/run-parts"
      # Docker settings.
      container.vm.provider "docker" do |d|
        docker_args = [
          "--network=#{net_name}",
          "--ip",
          "#{service_conf["net_ip"]}",
          "--volume",
          "ce-vm-cache:#{guest_ce_home}/cache",
          "--volume",
          "/var"
        ]
        if(service_conf["docker_extra_args_#{host_platform}"])
          service_conf["docker_extra_args_#{host_platform}"].each do |arg|
            docker_args.push(arg)
          end
        end
        # We need to run in privileged mode for sshfs.
        if(service_conf['volume_type'] === 'sshfs')
          d.privileged = true
        end
        d.force_host_vm = false
        d.image = service_conf['docker_image']
        d.name = "#{name}"
        d.has_ssh = true
        d.volumes = volumes
        if (service_conf["net_fwd_ports_#{host_platform}"])
          d.ports = service_conf["net_fwd_ports_#{host_platform}"]
        end
        d.create_args = docker_args
        d.cmd = ["/bin/sh", "/opt/ce-vm-start.sh", "#{service_conf['docker_vagrant_user_uid']}", "#{service_conf['docker_vagrant_group_gid']}"]
      end
    end
  end
  ################# END Individual container.
end
