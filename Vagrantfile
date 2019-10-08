# -*- mode: ruby -*-
# vi: set ft=ruby :

################ Bootstrap.

# Load our utilities.
files = %w[ansible ce_vm common config docker host init service utils vagrant]
path = File.dirname(File.expand_path(__FILE__))
files.each do |file|
  require File.join(path, 'vagrant', "#{file}.rb")
end
################ Initial setup.

# Ensure we are not run as root.
host_ensure_user_not_root

# Ensure we're on the right branch first.
ce_vm_ensure_branch
if ARGV.include? 'up'
  # Ensure we have the needed Vagrant version.
  vagrant_ensure_version
  # Ensure we have the needed Vagrant plugins.
  vagrant_ensure_plugins
  # Ensure ce-vm is up-to-date.
  ce_vm_uptodate
  # Create our private Docker network.
  # docker_ensure_network
end

# Note: actual processing is in init.rb
