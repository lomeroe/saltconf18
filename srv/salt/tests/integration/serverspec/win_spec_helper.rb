require 'rubygems'
require 'bundler/setup'

require 'serverspec'
require 'pathname'
require 'winrm'

set :backend, :winrm
set :os, :family => 'windows'

opts = {
    endpoint: "http://#{ENV['KITCHEN_HOSTNAME']}:#{ENV['KITCHEN_PORT']}/wsman",
    transport: :plaintext,
    user: ENV['KITCHEN_USERNAME'],
    password: ENV['KITCHEN_PASSWORD'],
    basic_auth_only: true,
    operation_timeout: 300
}
@winrm = WinRM::Connection.new(opts)
Specinfra.configuration.winrm = @winrm