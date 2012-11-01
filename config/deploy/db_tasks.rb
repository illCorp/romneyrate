namespace :db do
  desc "Reinit the db completely (drop | create | migrate | seed | etc.)"
  task :reinit, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake db:drop db:create db:migrate db:seed"
  end

  task :migrate, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake db:migrate"
  end
  
  desc "Backup the DB to S3"
  task :backup, :roles => :app do
    source = rails_env if source.nil?
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake db:backup[#{source}] --trace"
  end
  
  desc "Migrate data from one Environment to Another"
  task :push, :roles => :app do
    raise "ERROR: this task will not migrate data to production, since this could royally screw something up." if target=="production"
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake \"db:push[#{source}, #{target}]\""
  end
end
