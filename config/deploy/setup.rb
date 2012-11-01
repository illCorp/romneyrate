set :whenever_command, "bundle exec whenever"
def mailer(options)
  Mail.defaults do
    delivery_method :smtp, options
  end
end

def multistage_info(stages, default="staging")
  set :stages, stages
  set :default_stage, default
  puts "stages: #{stages}"
  require "capistrano/ext/multistage"
end

def application_info(app_name)
  set :application, app_name
  set :deploy_to, "/home/ubuntu/#{app_name}"
  set :deploy_via, :remote_cache
  set :deploy_env, "production"
end

def ssh_info
  set :use_sudo, true                           # Needed for deploy:cleanup being called after deploy
  set :keep_releases, 4
  default_run_options[:pty] = true
  ssh_options[:forward_agent] = true
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ec2", "meeps.pem")]

  set :user, "ubuntu"
  set :runner, "ubuntu"
end

def scm_info
  set :scm, :git
  set :scm_username, "szehnder"
  set :repository, "git@github.com:illCorp/romneyrate.git"
end

def unicorn_info
  set :unicorn_binary, "/usr/local/bin/unicorn"
  set :unicorn_config, "#{current_path}/config/unicorn.rb"
  set :unicorn_pid, "/home/ubuntu/romneyrate/shared/pids/unicorn.pid"
end

def self.method_missing(method_sym, *args, &block)
  if method_name = /setup_(\w+)/.match(method_sym.to_s)
    logger.info "#{method_sym.to_s} starting..."
    send(method_name[1].to_sym, *args)
    logger.info "#{method_sym.to_s} finished!"
  else
    super
  end
end
