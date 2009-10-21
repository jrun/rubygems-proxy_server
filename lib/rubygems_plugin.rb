require 'rubygems/command_manager'
require 'rubygems/local_remote_options'
require 'rack'

class File
  alias to_path path
end

class Gem::Commands::ProxyServerCommand < Gem::Command
  include Gem::LocalRemoteOptions
  
  class App
    def basedir
      File.expand_path('/home/jtburks/tmp/gem_server')
    end
      
    def call(env)
      puts "Request: #{env['PATH_INFO']}"

      status = 200
      headers = {'Content-Type' => 'text/plain'}
      
      path = File.join(basedir, env['PATH_INFO'].to_s)
      
      unless File.file?(path) && File.readable?(path)
        status = 404
      else        
        headers['Content-Length'] = File.size(path).to_s
      end
      
      [status, headers, File.new(path, 'r')]
    end      
  end
  
  def initialize
    super "proxy_server", "A proxy server"
  end
  
  def execute
    Rack::Handler::Mongrel.run App.new, :Port => 9292
  end
end

Gem::CommandManager.instance.register_command :proxy_server

 
