require 'rubygems'
require 'bundler/setup'

require 'serverspec'
require 'pathname'
require 'net/ssh'
require 'spec_helper_common_functions'

the_host = ENV['RSPEC_HOSTNAME'] ? ENV['RSPEC_HOSTNAME'] : getserver
the_user = ENV['RSPEC_USERNAME'] ? ENV['RSPEC_USERNAME'] : getuser
the_authmethod = ENV['RSPEC_AUTHMETHOD'] ? ENV['RSPEC_AUTHMETHOD'].split(',') : getauthmethod
the_keys = []
the_password = ''
disable_sudo = true

if the_authmethod.include? 'keyboard-interactive'
    the_password = ENV['RSPEC_PASSWORD'] ? ENV['RSPEC_PASSWORD'] : getpw
end
if the_authmethod.include? 'publickey'
    the_keys = [ ENV['RSPEC_SSH_KEY'] ? ENV['RSPEC_SSH_KEY'] : getkeys ]
end
if the_user == 'root'
    disable_sudo = false
end

RSpec.configure do |config|
  set :host, the_host
  # ssh options at http://net-ssh.github.io/net-ssh/Net/SSH.html#method-c-start
  # ssh via ssh key (only)
  set :ssh_options,
    :user => the_user,
    :port => 22,
    :auth_methods => the_authmethod,
    :keys => the_keys,
    :keys_only => true,
    :password => the_password,
    :verify_host_key => :never,
    :verbose => :error
  set :backend, :ssh
  set :disable_sudo, disable_sudo
  set :request_pty, true
end