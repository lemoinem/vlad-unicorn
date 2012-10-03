require 'vlad-unicorn/version'
require 'vlad'

module Vlad
  module Unicorn
    # Runs +cmd+ using sudo if the +:unicorn_use_sudo+ variable is set.
    def self.maybe_sudo(cmd)
      cmd = %(cd "#{current_path}" && #{cmd})
      if unicorn_use_sudo
        sudo %(sh -c '#{cmd}')
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

    def self.if_not_signal(sig, cmd)
      %(if ! test -s "#{unicorn_pid}" || ! #{signal(sig)} ; then #{cmd} ; fi)
    end

    def self.signal(sig = '0')
      %(kill -#{sig} "$(cat "#{unicorn_pid}")")
    end

    def self.start(opts = '')
      maybe_sudo if_not_signal(unicorn_restart_signal,
                               %(#{unicorn_command} -D --config-file "#{unicorn_config}" #{opts}))
    end

    def self.stop
      maybe_sudo if_not_signal('QUIT',
                               %(echo "stale pid file #{unicorn_pid}" ; rm -f "#{unicorn_pid}"))
    end
  end
end

namespace :vlad do
  set :unicorn_command,     "unicorn"
  set(:unicorn_config)      { "#{current_path}/config/unicorn.rb" }
  set :unicorn_use_sudo,    false
  set(:unicorn_pid)         { "#{shared_path}/pids/unicorn.pid" }
  set :unicorn_use_preload, false
  set(:ancillary_dir)       { old_ancillary_dir +
    [
     File.dirname(unicorn_pid),
     "#{shared_path}/logs"
    ] }

  desc "Stop the app servers"
  remote_task :stop_app, :roles => :app do
    Vlad::Unicorn.stop
  end
end
