################################################################################
################ Vagrant checks and utilities.
################################################################################

VAGRANTFILE_API_VERSION = '2'.freeze unless defined? VAGRANTFILE_API_VERSION
# Prevent Vagrant from looking for VBox.
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'
# We need to control order,
# so can't process provisioning in parallel.
ENV['VAGRANT_NO_PARALLEL'] = 'yes'
# Ensure this is not nil.
ENV['VAGRANT_DOTFILE_PATH'] = '.vagrant' if ENV['VAGRANT_DOTFILE_PATH'].nil?

# We currently use only one plugin, so skip iterating.
def vagrant_ensure_plugins
  plugin = 'vagrant-hostsupdater'
  return unless config_get_item('skip_vagrant_plugins_check') == true
  system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin.to_s
end

# Ensure Vagrant meets version requirements.
def vagrant_ensure_version
  Vagrant.require_version '>= 2.2.0'
end
