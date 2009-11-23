require 'rubygems/local_remote_options'
require 'proxy_app'

class Gem::Commands::ProxyServerCommand < Gem::Command
  include Gem::LocalRemoteOptions

  PROXY_DEFAULT_GEM_SOURCE = "http://gemcutter.org"
  PROXY_DEFAULT_PORT = 3027
  
  NIL_DIR_MSG = "missing -d, --directory option"
  
  def initialize
    super "proxy_server", summary

    accept_uri_http
    
    add_option '-d', '--directory BASEDIR',
      'Repository base dir containing gems subdir.' do |dir, options|
      options[:directory] = File.expand_path dir
    end

    add_option '-s', '--source URL', URI::HTTP,
      'The remote source for gems.' do |source, options|
      options[:remote_source] = source
    end

    add_option '-p', '--port PORT',
      'The port of the gem source.'  do |port, options|
      options[:port] = port.to_i
    end    
  end

  def summary
    "Half gem source, half gem proxy."
  end
  
  def description # :nodoc:
    <<-EOS
The directory given via -d, --directory is expected to be a gem
server directory. See `gem help generate_index` for the requirements
for that directory.

  $ gem proxy_server -d /var/www/gems

  EOS
  end

  def usage # :nodoc:
    program_name
  end
  
  def defaults_str # :nodoc:
    "--port #{PROXY_DEFAULT_PORT} --source #{PROXY_DEFAULT_GEM_SOURCE}"
  end
  
  def execute
    dir = options[:directory]
    if dir.nil?
      alert_error NIL_DIR_MSG
      terminate_interaction 1
    elsif not File.exist?(dir) or not File.directory?(dir)
      alert_error "unknown directory name #{dir}."
      terminate_interaction 1
    else
      ProxyApp.run! :port => options[:port] || PROXY_DEFAULT_PORT,
        :source => options[:remote_source] || PROXY_DEFAULT_GEM_SOURCE,
        :public => dir
    end
  end
end
