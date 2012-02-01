require File.join(File.dirname(__FILE__), "lib", "dm-chef-adapter", "version")  # For DM-CHEF-ADAPTER_VERSION

Gem::Specification.new do |spec|
  files = []
  paths = %w{lib examples}
  paths.each do |path|
    if File.file?(path)
      files << path
    else
      files += Dir["#{path}/**/*"]
    end
  end

  rev = Time.now.strftime("%Y%m%d%H%M%S")
  spec.name = "dm-chef-adapter"
  spec.version = LOGSTASH_VERSION
  spec.summary = "datamapper adapter to use a chef server as a datastore backend"
  spec.description = "uses chef databags as a backend for the datamapper ORM"
  spec.license = "Apache License (2.0)"

  spec.add_dependency "chef", "0.10.8"
  spec.add_dependency "dm-core", "1.2.0"
  spec.add_dependency "dm-serializer", "1.2.1"

  spec.files = files
  spec.require_paths << "lib"

  spec.authors = ["Nick Ethier"]
  spec.email = ["ncethier@gmail.com"]
  spec.homepage = "https://github.com/nickethier/dm-chef-adapter"
end

