require 'rubygems'
require 'bundler/setup'
require 'io/console'
require 'serverspec'
require 'pathname'
require 'winrm'
require 'spec_helper_common_functions'

set :backend, :winrm
set :os, :family => 'windows'


the_host = ENV['RSPEC_HOSTNAME'] ? ENV['RSPEC_HOSTNAME'] : getserver
the_port = ENV['RSPEC_PORT'] ? ENV['RSPEC_PORT'] : getport
use_ssl = the_port.to_s == '5986' ? 's' : ''
the_transport = the_port.to_s == '5986' ? :ssl : :negotiate

opts = {
    endpoint: "http#{use_ssl}://#{the_host}:#{the_port}/wsman",
    transport: the_transport,
    user: "#{ENV['RSPEC_USERNAME'] ? ENV['RSPEC_USERNAME'] : getuser}",
    password: "#{ENV['RSPEC_PASSWORD'] ? ENV['RSPEC_PASSWORD'] : getpw}",
    operation_timeout: 300,
    no_ssl_peer_verification: true
}

@winrm = WinRM::Connection.new(opts)
Specinfra.configuration.winrm = @winrm
