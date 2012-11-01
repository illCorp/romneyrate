before :deploy do
  unless exists? :rails_env
    raise "Environment not implemented"
  end
end


before "deploy", "deploy:record_start"
after 'deploy:update_code', 'bundler:symlink_bundled_gems'
after 'deploy:update_code', 'bundler:install'
after 'deploy:restart', 'deploy:cleanup'
after "deploy:cleanup", "deploy:record_success"
after "servers:reboot", "deploy:record_reboot"
after "rollback", "deploy:record_failure"