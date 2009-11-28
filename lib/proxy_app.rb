require 'rubygems/indexer'
require 'sinatra/base'
require 'net/http'
require 'pathname'

class ProxyApp < Sinatra::Base
  enable :run
  disable :static

  set :environment, :production
  
  get '/' do
    <<-EOS
directory: #{options.public}
gem_source: #{options.source}
EOS
  end
  
  get '/gems/*' do
    filename = File.join params[:splat]
    gemfile_path = gem_path.join filename
    
    unless gemfile_path.exist? 
      download_file "#{options.source}/gems/#{filename}", gemfile_path
      update_gem_index
    end

    send_file gemfile_path
  end

  get "/*" do
    path = File.join params[:splat]
    upstream_url = options.source + "/" + path
    tmpfile = tmp_path_for path

    download_file upstream_url, tmpfile
    
    send_file tmpfile
  end
  
  not_found do
    "\n"
  end

  private
  def public_path
    @public_path ||= Pathname.new(options.public)
  end
  
  def gem_path
    @gem_path ||= public_path.join('gems')
  end
  
  def download_file(url, local_path)
    Net::HTTP.get_response(URI.parse(url)) do |res| 
      case res
      when Net::HTTPSuccess
        local_path.open("wb") do |f|
          res.read_body {|chunk| f.write(chunk) }
        end
      when Net::HTTPRedirection
        download_gem res['location'], local_path 
      else
        raise Sinatra::NotFound, url
      end
    end
  end
  
  def update_gem_index
    if options.respond_to? :mock_gem_indexer
      options.mock_gem_indexer
    else
      Gem::Indexer.new(options.public)
    end.generate_index
  end
  
  def tmp_path_for(path)
    tmpfile = Pathname.new File.join(tmp_path, path)
    unless tmpfile.dirname.exist?
      tmpfile.dirname.mkpath
    end
    tmpfile
  end
  
  # == Note
  #
  # There is a bug in JRuby [1]  with regard to renaming files
  # across devices. Create the tmp dir inside the public directory
  # to make sure the files will be on the same device. 
  #
  # [1] http://jira.codehaus.org/browse/JRUBY-3381
  #  
  def tmp_path
    tmpdir = File.join options.public, 'rubygems-proxy_server-cache'
    Dir.mkdir tmpdir unless File.exist?(tmpdir)
    ENV["TMPDIR"] = tmpdir

    tmpdir
  end
end

