################################################################################
################ ce-vm checks and utilities.
################################################################################

# Make sure the local ce-vm repo is on the right version branch.
def ce_vm_ensure_branch
  upstream = path_get_ce_vm_upstream_repo
  branch = ENV['CE_VM_UPSTREAM_BRANCH']
  Vagrant::Util::Subprocess.execute('git', '-C', upstream, 'checkout', branch)
end

# Make sure the local ce-vm repo is up-to-date with remote version branch.
def ce_vm_uptodate
  return if config_get_item('ce_vm_auto_update') == false
  puts 'Ensure ce-vm is up-to-date.'
  upstream = path_get_ce_vm_upstream_repo
  branch = ENV['CE_VM_UPSTREAM_BRANCH']
  Vagrant::Util::Subprocess.execute('git', '-C', upstream, 'fetch')
  Vagrant::Util::Subprocess.execute('git', '-C', upstream, 'checkout', branch)
  Vagrant::Util::Subprocess.execute('git', '-C', upstream, 'pull', 'origin', branch)
  ce_vm_ensure_branch
end
