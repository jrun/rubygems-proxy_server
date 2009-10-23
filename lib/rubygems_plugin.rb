require 'rubygems/command_manager'
require 'proxy_server_command'

Gem::CommandManager.instance.register_command :proxy_server
