require "whenever/capistrano"
set :rails_env, "staging"
set :whenever_environment, defer { rails_env }
set(:whenever_command) { "RAILS_ENV=#{rails_env} bundle exec whenever" }
set :branch, "master"
set :recipients, %w(sean@meeps.com mranauro@meeps.com)

server "ec2-184-73-62-49.compute-1.amazonaws.com", :app, :web, :db, :assets, primary: true
#server "ec2-184-72-181-207.compute-1.amazonaws.com", :app, :web, :db, primary: true
#server "ec2-174-129-131-101.compute-1.amazonaws.com", :app, :web, :db, primary: true
