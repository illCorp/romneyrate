require 'fileutils'

module Z
module Sprockets
  class StaticCompiler
    attr_accessor :env, :target, :paths

    def initialize(env, target, paths, options = {})
      @env = env
      @target = target
      @paths = paths
      @digest = options.key?(:digest) ? options.delete(:digest) : true
      @manifest = options.key?(:manifest) ? options.delete(:manifest) : true
      @manifest_path = options.delete(:manifest_path) || target
#      puts "initialized the static compiler."
    end

    def compile
#      puts "compiling..."
      manifest = {}
      env.each_logical_path do |logical_path|
        next unless compile_path?(logical_path)
        if asset = env.find_asset(logical_path)
          manifest[logical_path] = write_asset(asset)
        end
      end
      f = write_manifest(manifest) if @manifest
      puts "done with compile"
      f
    end

    def write_manifest(manifest)
      puts "writing manifest..."
      puts "manifest path: #{@manifest_path}"
      FileUtils.mkdir_p(@manifest_path)
      f = File.open("#{@manifest_path}/manifest.yml", 'wb') do |f|
        YAML.dump(manifest, f)
      end
    end

    def write_asset(asset)
      #puts "writing asset..."
      path_for(asset).tap do |path|
        filename = File.join(target, path)
        FileUtils.mkdir_p File.dirname(filename)
        asset.write_to(filename)
        asset.write_to("#{filename}.gz") if filename.to_s =~ /\.(css|js)$/
      end
    end

    def compile_path?(logical_path)
#      puts "compile_path?..."
      paths.each do |path|
        case path
        when Regexp
          return true if path.match(logical_path)
        when Proc
          return true if path.call(logical_path)
        else
          return true if File.fnmatch(path.to_s, logical_path)
        end
      end
      false
    end

    def path_for(asset)
      @digest ? asset.digest_path : asset.logical_path
    end
  end
end
end
