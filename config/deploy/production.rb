require "whenever/capistrano"
set :rails_env, "production"
set :whenever_environment, defer { rails_env }
set(:whenever_command) { "RAILS_ENV=#{rails_env} bundle exec whenever" }
set :branch, "production"
set :recipients, %w(sean@meeps.com mranauro@meeps.com)
server "ec2-23-20-80-129.compute-1.amazonaws.com", :app, :web, :db, primary: true
