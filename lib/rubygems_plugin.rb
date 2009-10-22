require 'rubygems/command_manager'
require 'rubygems/local_remote_options'
require 'app'

class Gem::Commands::ProxyServerCommand < Gem::Command
  include Gem::LocalRemoteOptions

  DEFAULT_GEM_SOURCE = "http://gems.rubyforge.org"
  DEFAULT_PORT = 3027
  
  def initialize
    super "proxy_server", "Half gem source, half gem proxy."

    accept_uri_http
    
    add_option '-d', '--directory DIRNAME',
      'Repository base dir containing gems subdir.' do |dir, options|
      options[:directory] = File.expand_path dir
    end

    add_option '-s', '--source URL', URI::HTTP,
    "The remote source for gems. Defaults to #{DEFAULT_GEM_SOURCE}." do |source, options|
      options[:remote_source] = source
    end

    add_option '-p', '--port PORT',
    "The port of the gem source. Defaults to #{DEFAULT_PORT}." do |port, options|
      options[:port] = port.to_i
    end
    
  end
  
  def description # :nodoc:
    <<-EOS

The directory given via -d, --directory is expected to be a gem
source. See `gem help generate_index` for requirements.

  $ gem proxy_server -d /var/www/gems

  EOS
  end
  
  def usage # :nodoc:
    program_name
  end
  
  def execute
    dir = options[:directory]
    if not File.exist?(dir) or not File.directory?(dir) then
      alert_error "unknown directory name #{dir}."
      terminate_interaction 1
    else
      App.run! :port => options[:port] || DEFAULT_PORT,
        :source => options[:remote_source] || DEFAULT_GEM_SOURCE,
        :public => dir
    end
  end
end

Gem::CommandManager.instance.register_command :proxy_server

 
