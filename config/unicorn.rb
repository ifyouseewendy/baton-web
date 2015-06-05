# unicorn_rails -c /data/imigu/current/config/unicorn.rb -E production -D
rails_env =  'production'

# 10 workers and 1 master
# Sample verbose configuration file for Unicorn (not Rack)
#
# This configuration file documents many features of Unicorn
# that may not be needed for some applications. See
# http://unicorn.bogomips.org/examples/unicorn.conf.minimal.rb
# for a much simpler configuration file.
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.

# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
worker_processes 4

# root_path = "#{File.dirname(__FILE__)}/.."
root_path = "/home/deploy/apps/baton-web"


# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
preload_app true

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
working_directory root_path # available in 0.94.0+

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen "#{root_path}/tmp/unicorn.sock", :backlog => 409600

listen 9527, :tcp_nopush => true

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 8

# feel free to point this anywhere accessible on the filesystem
pid "#{root_path}/tmp/pids/unicorn.pid"

# By default, the Unicorn logger will write to stderr.
# Additionally, ome applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path "#{root_path}/log/unicorn.stderr.log"
stdout_path "#{root_path}/log/unicorn.stdout.log"

# REE
# combine REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  old_pid = root_path + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # per-process listener ports for debugging/admin/migrations
  # addr = "127.0.0.1:#{9293 + worker.nr}"
  # server.listen(addr, :tries => -1, :delay => 5, :tcp_nopush => true)

  # the following is *required* for Rails + "preload_app true",
  # defined?(ActiveRecord::Base) and
  #   ActiveRecord::Base.establish_connection

  if defined?(Mongoid)

    Mongoid.reconnect!

  end

  init_resque!

   # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end
