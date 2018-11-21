################################################################################
################ Docker Generic commands and utilities.
################################################################################

# Ensure private Docker network exists or create it.
def docker_ensure_network
  subnet = config_get_item('net_subnet')
  gateway = config_get_item('net_gateway')
  name = docker_network_get_name
  puts "Ensure private Docker network #{name} exists."
  existing_net = Vagrant::Util::Subprocess.new('docker', 'network', 'inspect', '--format={{range .IPAM.Config}}{{.Subnet}}{{end}}',  name.to_s).execute.stdout
  existing_gw = Vagrant::Util::Subprocess.new('docker', 'network', 'inspect', '--format={{range .IPAM.Config}}{{.Gateway}}{{end}}',  name.to_s).execute.stdout
  existing_net.strip!
  existing_gw.strip!
  if subnet != existing_net || gateway != existing_gw
    unless existing_net.empty?
      Vagrant::Util::Subprocess.new('docker', 'network', 'rm', name.to_s).execute
    end
    Vagrant::Util::Subprocess.new('docker', 'network', 'create', "--subnet=#{subnet}", "--gateway=#{gateway}", name.to_s).execute
  end
end

# Returns the name of our private Docker network.
def docker_network_get_name
  subnet = config_get_item('net_subnet')
  "ce-vm-#{subnet}"
end

# Forces the 'link' from Vagrant to Docker, as it can get lost in case of failure.
# This can only work because we have 'set' names, and container names are unique.
# See https://github.com/hashicorp/vagrant/issues/9958
def docker_ensure_vagrant_id(service_name)
  container_name = service_get_container_name(service_name)
  # We can not use trigger.run here because we need to process the result of the execution.
  docker_id = Vagrant::Util::Subprocess.execute('docker', 'inspect', '--format={{.Id}}', container_name).stdout.strip!
  # Nothing to do.
  return if docker_id.empty?
  # Check if we have a vagrant subfolder and id file.
  docker_id_file = File.join(fullpath_get_host_project_dir, 'ce-vm', ENV['VAGRANT_DOTFILE_PATH'], 'machines', service_name, 'docker', 'id')
  # No file, try to create it.
  docker_create_vagrant_id_file(docker_id_file) unless File.exist?(docker_id_file)
  # Check if ids match.
  stored_id = File.read(docker_id_file)
  # Nothing to do, everything matches.
  return if stored_id.to_s === docker_id.to_s
  #  Connection somehow got lost. Try to resume.
  docker_recreate_vagrant_id_file(docker_id_file, docker_id, container_name)
end

# Recreate id file to attempt a remap.
def docker_create_vagrant_id_file(docker_id_file)
  logger = Vagrant::UI::Colored.new
  logger.warn("WARNING: Missing internal Vagrant marker file `#{docker_id_file}`. Trying to recreate it.")
  File.new(docker_id_file, 'w')
end

# Recreate id file to attempt a remap.
def docker_recreate_vagrant_id_file(docker_id_file, docker_id, container_name)
  logger = Vagrant::UI::Colored.new
  logger.warn("WARNING: the container #{container_name} exists, but is not present in Vagrant machine index.")
  logger.warn("This should not happen under normal operations and indicates the container failed to start properly or was not stopped properly.")
  logger.warn("Attempting to remap the container to Vagrant. The safest is to delete the container with `docker stop #{docker_id} && docker rm #{docker_id}` and start from fresh.")
  File.write(docker_id_file, docker_id)
end

# Wraps docker check in a Vagrant trigger.
def docker_trigger_ensure_vagrant_id(trigger, service_name)
  container_name = service_get_container_name(service_name)
  trigger.name = "Ensure consistency of Vagrant registry for #{container_name} container."
  trigger.ruby do
    docker_ensure_vagrant_id(service_name, container_name)
  end
end
