require 'vlad-unicorn/version'
require 'vlad'

module Vlad
  module Unicorn
    # Runs +cmd+ using sudo if the +:unicorn_use_sudo+ variable is set.
    def self.maybe_sudo(cmd)
      if unicorn_use_sudo
        sudo cmd
      else
        run cmd
      end
    end

    def self.unicorn_restart_signal
      if unicorn_use_preload
        'USR2'
      else
        'HUP'
      end
    end

    def self.signal(sig = '0')
      %(test -s "#{unicorn_pid}" && kill -#{sig} `cat "#{unicorn_pid}"`)
    end

    def self.start(opts = '')
      cmd = signal(unicorn_restart_signal)
      cmd << %( || (#{unicorn_command} -D --config-file #{unicorn_config} #{opts}))
      maybe_sudo %(sh -c '#{cmd}')
    end

    def self.stop
      cmd = signal('QUIT')
      cmd << %( || echo "stale pid file #{unicorn_pid}")
      maybe_sudo %(sh -c '#{cmd}')
    end
  end
end

namespace :vlad do
  set :unicorn_command,     "unicorn"
  set(:unicorn_config)      { "#{current_path}/config/unicorn.rb" }
  set :unicorn_use_sudo,    false
  set(:unicorn_pid)         { "#{shared_path}/pids/unicorn.pid" }
  set :unicorn_use_preload, false

  desc "Stop the app servers"
  remote_task :stop_app, :roles => :app do
    Vlad::Unicorn.stop
  end
end
