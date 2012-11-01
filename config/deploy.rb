require "mail"
require 'capistrano_colors'

load "config/deploy/setup"
load "config/deploy/tasks"
load "config/deploy/hooks"
load "config/deploy/mailer"
load 'config/deploy/db_tasks'
#load 'deploy/assets'

# Add RVM's lib directory to the load path.
#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

# Load RVM's capistrano plugin.    
require "rvm/capistrano"

set :rvm_ruby_string, 'ruby-1.9.3-p125@romneyrate-web'
set :rvm_type, :user  # Don't use system-wide RVM

setup_mailer DeployMailer.options
setup_multistage_info %w(production staging)
setup_application_info "romneyrate"
setup_ssh_info
setup_scm_info
setup_unicorn_info
depend :remote, :gem, "bundler", ">=1.0.18"
