################################################################################
################ Helper functions.
################################################################################

require 'yaml'

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
    conf.merge!(YAML.load_file(config_file)) if File.exist?(config_file)
  end
  conf = parse(conf)
  conf
end

# Build a list of files.
def build_file_list(dirs, filenames)
  files = []
  filenames.each do |filename|
    dirs.each do |dir|
      files.push(File.join(dir, filename))
    end
  end
  files
end

# Filter existing files for guest.
def filter_file_list(host_files, run_files)
  filtered = []
  host_files.each.with_index do |h_file, key|
    filtered.push(run_files[key]) if File.exist?(h_file)
  end
  filtered
end
