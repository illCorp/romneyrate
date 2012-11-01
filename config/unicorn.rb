APP_ROOT = File.expand_path(File.dirname(File.dirname(__FILE__)))
ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', File.dirname(__FILE__))
require 'bundler/setup'

rails_env = ENV['RAILS_ENV'] || 'production'

worker_processes 8 #(rails_env == 'production' ? 4 : 4)

preload_app true

timeout 60

working_directory APP_ROOT

listen '/home/ubuntu/she-services/shared/sockets/unicorn.sock', :backlog => 2048

pid '/home/ubuntu/she-services/shared/pids/unicorn.pid'
old_pid = '/home/ubuntu/she-services/shared/pids/unicorn.pid.oldbin'
stderr_path APP_ROOT + "/log/unicorn.stderr.log"
stdout_path APP_ROOT + "/log/unicorn.stdout.log"

if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
     ActiveRecord::Base.connection.disconnect!
     # The following is only recommended for memory/DB-constrained
      # installations.  It is not needed if your system can house
      # twice as many worker_processes as you have configured.
      #
      # # This allows a new master process to incrementally
      # # phase out the old master process with SIGTTOU to avoid a
      # # thundering herd (especially in the "preload_app false" case)
      # # when doing a transparent upgrade.  The last worker spawned
      # # will then kill off the old master process with a SIGQUIT.
      # old_pid = "#{server.config[:pid]}.oldbin"
      # if old_pid != server.pid
      #   begin
      #     sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      #     Process.kill(sig, File.read(old_pid).to_i)
      #   rescue Errno::ENOENT, Errno::ESRCH
      #   end
      # end
      #
      # Throttle the master from forking too quickly by sleeping.  Due
      # to the implementation of standard Unix signal handlers, this
      # helps (but does not completely) prevent identical, repeated signals
      # from being lost when the receiving process is busy.
      # sleep 1
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
      
      #this is an alternative found here http://stackoverflow.com/questions/5794176/restart-unicorn-with-a-usr2-quitting-old-master
      # sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      # Process.kill(sig, File.read(old_pid).to_i)

    rescue Errno::ENOENT, Errno::ESRCH
      puts "Old master alerady dead"
    end
  end
end


after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true",
    defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection

    # if preload_app is true, then you may also want to check and
    # restart any other shared sockets/descriptors such as Memcached,
    # and Redis.  TokyoCabinet file handles are safe to reuse
    # between any number of forked children (assuming your kernel
    # correctly implements pread()/pwrite() system calls)
end
