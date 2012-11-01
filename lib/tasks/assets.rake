require "fileutils"
require "z_static_compiler"
require 'asset_sync'

@@foo = nil
namespace :z do
  namespace :assets do
    def ruby_rake_task(task, fork = true)
      env    = ENV['RAILS_ENV'] || 'production'
      groups = ENV['RAILS_GROUPS'] || 'assets'
      args   = [$0, task,"RAILS_ENV=#{env}","RAILS_GROUPS=#{groups}"]
      args << "--trace" if Rake.application.options.trace
      fork ? ruby(*args) : Kernel.exec(FileUtils::RUBY, *args)
    end

    # We are currently running with no explicit bundler group
    # and/or no explicit environment - we have to reinvoke rake to
    # execute this task.
    def invoke_or_reboot_rake_task(task)
      if ENV['RAILS_GROUPS'].to_s.empty? || ENV['RAILS_ENV'].to_s.empty?
        ruby_rake_task task
      else
        Rake::Task[task].invoke
      end
    end

    desc "Compile all the assets named in config.assets.precompile"
    task :precompile do
      Rake::Task["z:assets:precompile:all"].invoke
      #    invoke_or_reboot_rake_task "z:assets:precompile:all"
    end

    namespace :precompile do
      def internal_precompile(digest=nil)
        unless Rails.application.config.assets.enabled
          warn "Cannot precompile assets if sprockets is disabled. Please set config.assets.enabled to true"
          exit
        end

        # Ensure that action view is loaded and the appropriate
        # sprockets hooks get executed
        _ = ActionView::Base

        config = Rails.application.config
        config.assets.compile = true
        config.assets.digest  = digest unless digest.nil?
        config.assets.digests = {}

        env      = Rails.application.assets
        target   = File.join(Rails.public_path, config.assets.prefix)
      
        compiler = Z::Sprockets::StaticCompiler.new(env,
        target,
        config.assets.precompile,
        :manifest_path => config.assets.manifest,
        :digest => config.assets.digest,
        :manifest => digest.nil?)
        begin
          compiler.compile
        rescue Exception => e
          puts "EXCEPTION IN PRECOMPILER !! -- "
          puts e
        end
        true
      end

      task :all do
        Rake::Task["z:assets:precompile:primary"].invoke
        # We need to reinvoke in order to run the secondary digestless
        # asset compilation run - a fresh Sprockets environment is
        # required in order to compile digestless assets as the
        # environment has already cached the assets on the primary
        # run.
        ruby_rake_task("z:assets:precompile:nondigest", false) if Rails.application.config.assets.digest
        Rake::Task["z:assets:precompile:teardown"].invoke
      end
    
      task :teardown do
        AssetSync.sync
        puts "Asset Compilation and Sync Complete"
        puts @@foo
        #      Kernel.exit!
      end

      task :primary => ["z:assets:environment", "tmp:cache:clear"] do
        internal_precompile
      end

      task :nondigest => ["z:assets:environment", "tmp:cache:clear"] do
        puts "running nondigest version"
        internal_precompile(false)
      end
    end

    desc "Remove compiled assets"
    task :clean do
      invoke_or_reboot_rake_task "z:assets:clean:all"
    end

    namespace :clean do
      task :all => ["z:assets:environment", "tmp:cache:clear"] do
        config = Rails.application.config
        public_asset_path = File.join(Rails.public_path, config.assets.prefix)
        rm_rf public_asset_path, :secure => true
      end
    end

    task :environment do
      if Rails.application.config.assets.initialize_on_precompile
        puts "loading the rails environment."
        Rake::Task["environment"].invoke
      else
        puts "skipping the load of the rails environment"
        Rails.application.initialize!(:assets)
        begin
          @@foo = Sprockets::Bootstrap.new(Rails.application).run
        rescue Exception => e
          puts "I rescued the sprockets bootstrap thingy"
        end
      end
    end
  end
end
