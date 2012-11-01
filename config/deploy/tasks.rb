namespace :sanity do
  task :default do
    uname
  end
  task :uname do
    run "uname -a"
  end
end

namespace :servers do
  task :boostrap, roles: :app do
    raise "FIX ME"
  end
  task :reboot, roles: :app do
    p "This REBOOTS the app server and notifies all recipients for #{rails_env}. Are you sure? Type 'yes':"
    response = STDIN.gets.strip
    if response == "yes"
      run "sudo reboot"
    end
  end
end

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do
    run "/etc/init.d/unicorn start"
  end

  task :stop, :roles => :app, :except => { :no_release => true } do
    run "/etc/init.d/unicorn stop"
  end

  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "sudo kill -s QUIT `cat #{unicorn_pid}`"
  end

  task :reload, :roles => :app, :except => { :no_release => true } do
    run "/etc/init.d/unicorn upgrade"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    reload
  end

  task :restart_nginx, :roles => :app do
    run "/etc/init.d/nginx restart"
  end

  desc "Deployment Logger: Kicked Off"
  task :record_start do
    DeployMailer.send_notification("SheServices [#{rails_env}] Deployment Started", "A deployment to SheServices #{rails_env} has been started at #{Time.now}.", recipients.join(","))
  end

  desc "Deployment Logger: Record Success"
  task :record_success do
    DeployMailer.send_notification("SheServices [#{rails_env}] Deployment Successful", "The deployment to SheServices #{rails_env} successfully completed at #{Time.now}.", recipients.join(","))
  end

  desc "Deployment Logger: Record Failure"
  task :record_failure do
    DeployMailer.send_notification("SheServices [#{rails_env}] Deployment Failed", "The deployment to SheServices #{rails_env} failed at #{Time.now}.", recipients.join(","))
  end

  task :record_reboot do
    DeployMailer.send_notification("SheServices [#{rails_env}] Rebooted", "The server for SheServices #{rails_env} was rebooted at #{Time.now}.", recipients.join(","))
  end
end

namespace :nginx do  
  namespace :refresh do
    desc "Move the nginx configuration file into place"
    task :config, :roles => :app do
      run "cd #{current_path} && sudo cp config/etc/nginx/sites-available/*.conf /etc/nginx/sites-available/"
      run "sudo /etc/init.d/nginx restart"
    end
    
    desc "Move the ssl files into the right place"
    task :ssl, :roles => :app do
      #run "cd #{current_path} && sudo cp config/certs/illphotobooth.com/*.crt /etc/certs/"
      run "sudo mkdir -p /usr/local/nginx/ssl"
      run "sudo chmod 600 /usr/local/nginx/ssl"
      run "cd #{current_path} && sudo cp config/certs/illphotobooth.com/*.illphotobooth.com.* /usr/local/nginx/ssl/"
      run "cd #{current_path} && sudo cp config/certs/illphotobooth.com/illphotobooth.com.* /usr/local/nginx/ssl/"
    end
  end
end

namespace :remote_syslog do
  desc "update the remote_syslog init.d script"
  task :config, :roles => :app do
    run "cd #{current_path} && sudo cp config/etc/init.d/remote_syslog /etc/init.d/"
    run "cd #{current_path} && sudo cp config/etc/log_files.yml /etc/"
    run "sudo chmod +x /etc/init.d/remote_syslog"
    run "/etc/init.d/remote_syslog restart"
  end
end

namespace :unicorn do
  namespace :initd do
    task :config, :roles => :app do
      run "cd #{current_path} && sudo cp config/etc/init.d/unicorn /etc/init.d/"
      run "sudo chmod +x /etc/init.d/unicorn"
      run "sudo /etc/init.d/unicorn restart"
    end
  end
end

namespace :initd do  
  #this h
  desc "(DEPRECATED) zmq_sinatra has been replaced by zmq_redis"
  task :zmq_sinatra, :roles => :app do
    #run "cd #{current_path} && sudo cp config/etc/init.d/zmq_sinatra /etc/init.d/"
    #run "sudo chmod +x /etc/init.d/zmq_sinatra"
  end
  
  #upgraded the broker to zmq_redis as of 5.3.12
  desc "Remove the old zmq_sinatra scripts"
  task :remove_zmq_sinatra, :roles => :app do
    run "sudo /etc/init.d/zmq_sinatra stop"
    run "sudo update-rc.d -f zmq_sinatra remove"
    run "sudo rm /etc/init.d/zmq_sinatra"    
  end

  #upgraded the broker to zmq_redis as of 5.3.12
  desc "Installs the zmq_redis initd script"
  task :zmq_redis, :roles => :app do
    run "cd #{current_path} && sudo cp config/etc/init.d/zmq_redis /etc/init.d/"
    run "sudo chmod +x /etc/init.d/zmq_redis"
    run "sudo update-rc.d -f zmq_redis defaults"
    run "/etc/init.d/zmq_redis start"
  end

end 

namespace :monit do
  desc "install monit"
  task :install, :roles => :app do
    run "sudo apt-get install monit"
  end
  
  desc "refresh the configuration files"
  task :config, :roles => :app do
    run "sudo rm /etc/monit/conf.d/*.conf" #first, remove all the existing monit scripts
    run "cd #{current_path} && sudo cp config/etc/monit/conf.d/*.* /etc/monit/conf.d/" #then re-copy all the ones from illphoto source
    run "cd #{current_path} && sudo cp config/etc/monit/monitrc /etc/monit/" #make sure to refresh the main monit config
    run "sudo chown root:root /etc/monit/monitrc" #make sure permissions on that monit config are correct
    run "sudo /etc/init.d/monit restart"
  end
  
  #this broker zmq-sinatra has been replaced by zmq_redis
  namespace :zmq_sinatra do
    desc "start zmq_broker"
    task :start, :roles => :app do
      run "sudo monit start zmq_sinatra"
    end
    
    desc "stop zmq_broker"
    task :stop, :roles => :app do
      run "sudo monit stop zmq_sinatra"      
    end
    
    desc "restart zmq_broker"
    task :restart, :roles => :app do
      stop
      start
    end
  end

  #the new broker as of 5.4.12 - S. Zehnder
  namespace :zmq_redis do
    desc "start zmq_redis"
    task :start, :roles => :app do
      run "sudo monit start zmq_redis"
    end
    
    desc "stop zmq_redis"
    task :stop, :roles => :app do
      run "sudo monit stop zmq_redis"      
    end
  end
end

namespace :bundler do
  desc "Symlink bundled gems on each release"
  task :symlink_bundled_gems, :roles => :app do
    run "mkdir -p #{shared_path}/bundled_gems"
    run "ln -nfs #{shared_path}/bundled_gems #{release_path}/vendor/bundle"
  end

  desc "Install for production"
  task :install, :roles => :app do
    run "cd #{release_path} && RAILS_ENV=${rails_env} bundle install"
  end
end



namespace :delayed_job do
  task :config, :roles => :app do
    run "cd #{current_path} && sudo cp config/etc/init.d/delayed_job /etc/init.d/"
    run "sudo chmod +x /etc/init.d/delayed_job"
    run "sudo update-rc.d -f delayed_job defaults"
  end
  
  desc "Restart the delayed_job process"
  task :start, :roles => :app do
    run "sudo /etc/init.d/delayed_job start"
  end
  task :stop, :roles => :app do
    run "sudo /etc/init.d/delayed_job stop"
  end
  task :restart, :roles => :app do
    stop
    start
  end
end

namespace :twitter_stream do
  namespace :initd do
    task :config, :roles => :app do
      run "cd #{current_path} && sudo cp config/etc/init.d/twitter_stream /etc/init.d/"
      run "sudo chmod +x /etc/init.d/twitter_stream"
      run "sudo update-rc.d -f twitter_stream defaults"
    end
  end
  task :start, :roles => :app do
    run "sudo /etc/init.d/twitter_stream start"
  end
  task :stop, :roles => :app do
    run "sudo /etc/init.d/twitter_stream stop"    
  end
  task :restart, :roles => :app do
    run "sudo /etc/init.d/twitter_stream restart"    
  end
end

namespace :rapns do
  desc "Start RAPNS Daemon"
  task :start, :roles => :app do
    run "/etc/init.d/rapns start"
  end

  task :stop, :roles => :app do
    run "/etc/init.d/rapns stop"
  end

  task :restart, :roles => :app do
    stop
    start
  end
end

namespace :zmq do
  namespace :broker do
    desc "(DEPRECATED) Start zmq_sinatra Daemon"
    task :start, :roles => :app do
      #run "/etc/init.d/zmq_sinatra start"
    end

    task :stop, :roles => :app do
      #run "/etc/init.d/zmq_sinatra stop"
    end

    task :restart, :roles => :app do
      stop
      start
    end
  end
  
  namespace :upgrade do
    desc "Upgrade zmq library to 2.2"
    task :two_point_two, :roles => :app do
      run "cd temp && wget http://download.zeromq.org/zeromq-2.2.0.tar.gz && tar xzvf zeromq-2.2.0.tar.gz"
      run "cd temp/zeromq-2.2.0 && ./configure && make && sudo make install"
      run "gem install zmq -- --with-zmq-dir=/usr/local/lib"
    end
  end
end

namespace :redis do
  desc "Install latest redis-server"
  task :install, :roles => :app do
    #run "sudo add-apt-repository ppa:chris-lea/redis-server" #can't use this because it requires user input that doesn't play nice w/ capistrano
    run "sudo apt-get update"
    run "sudo apt-get install redis-server"
    run "cd #{current_path} && sudo cp config/etc/init.d/redis /etc/init.d/"
    run "sudo chmod +x /etc/init.d/redis"
    run "sudo update-rc.d -f redis defaults"
  end
  
  desc "Update Redis init.d script"
  task :initd, :roles => :app do
    run "sudo update-rc.d -f redis-server remove"
    run "cd #{current_path} && sudo cp config/etc/init.d/redis /etc/init.d/"
    run "sudo chmod +x /etc/init.d/redis"
    run "sudo update-rc.d -f redis defaults"
  end
  
  desc "start it up"
  task :start, :roles => :app do
    run "/etc/init.d/redis start"
  end
  
  desc "stop redis"
  task :stop, :roles => :app do
    run "/etc/init.d/redis stop"
  end
end

namespace :socketio_redis do
  namespace :nodejs do
    desc "install nodejs"  
    task :install, :roles => :app do
      run "sudo apt-get install nodejs npm --yes"
      run "sudo npm install coffee-script -g"
    end
  end
  
  namespace :initd do
    desc "Installs the socketio initd script"
    task :setup, :roles => :app do
      run "cd #{current_path} && sudo cp config/etc/init.d/socketio_redis /etc/init.d/"
      run "sudo chmod +x /etc/init.d/socketio_redis"
      run "sudo update-rc.d -f socketio_redis defaults"
      run "/etc/init.d/socketio_redis start"
    end
  end
  
  namespace :source do
    desc "initial clone of the repo"
    task :initial_clone, :roles => :app do
      run "git clone git@github.com:illCorp/socketio_redis.git"
      run "sudo npm install forever -g"
    end
  
    desc "update source code"
    task :pull, :roles => :app do
      cd "/home/ubuntu/socketio_redis && git pull"
    end
  end  
end
    

namespace :brokers do
  task :rebalance, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake brokers:rebalance --trace"
  end
end

namespace :logrotate do
  task :setup, :roles => :app do
    run "cd #{current_path} && sudo cp config/etc/logrotate.d/illphoto-logrotate /etc/logrotate.d/"
  end
  task :go, :roles => :app do
    run "cd #{current_path} && sudo /usr/sbin/logrotate -f /etc/logrotate.d/illphoto-logrotate"
  end
end

namespace :assets do
  desc "Precompile and deploy assets to S3"
  task :deploy, :roles => :assets do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake z:assets:precompile --trace"
  end
end

namespace :rvm do
  namespace :ruby do
    task :install, :roles => :app do
      run "rvm install ruby-1.9.3-p125 && rvm gemset create she-web"
    end
  end
end

namespace :gems do
  namespace :manual do
    task :install, :roles => :app do
      run "cd #{current_path} && ./script/install-rdebug.sh"
    end
  end
end



