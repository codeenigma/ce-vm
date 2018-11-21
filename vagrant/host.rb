################################################################################
################ Interactions with the host system.
################################################################################

# Return an user-friendly platform string for the current host.
def host_get_platform
  host_platform = 'windows'
  host_platform = 'mac_os' if RUBY_PLATFORM =~ /darwin/
  host_platform = 'linux' if RUBY_PLATFORM =~ /linux/
  host_platform.to_s
end

# Creates a loopback alias for a given service.
# Mac OS X specific, this allow access to containers
# without port-forwarding.
# @param Vagrant.trigger (by ref)
# param string
def host_trigger_ensure_lo_alias(trigger, service)
  ip = config_get_service_item(service, 'net_ip')
  trigger.name = "Ensure loopback interface alias exists for #{ip}."
  trigger.run = { inline: "sudo ifconfig lo0 alias #{ip}/32" }
end
