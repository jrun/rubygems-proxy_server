require 'rubygems/command_manager'
require 'rubygems/local_remote_options'
require 'app'

class Gem::Commands::ProxyServerCommand < Gem::Command
  include Gem::LocalRemoteOptions
  
  def initialize
    super "proxy_server", "A proxy server"
  end
  
  def execute
    App.run! :port => 5678,
      :public => '/home/tmp/gem_server',
      :source => 'http://gems.rubyforge.org'
  end
end

Gem::CommandManager.instance.register_command :proxy_server

 
