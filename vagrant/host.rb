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

# Prevent users to run Vagrant as root.
def host_ensure_user_not_root
  if Process.uid < 1
    puts 'Do not run Vagrant as root. See https://github.com/codeenigma/ce-vm/wiki/installation#linux-host on how to set up Docker securely instead.'
    abort
  end
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
