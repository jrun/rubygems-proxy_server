require 'rubygems/indexer'
require 'sinatra/base'
require 'pathname'
require 'net/http'

class App < Sinatra::Base
  enable :run
  disable :static

  set :environment, :production
  
  get '/' do
    "Gem this!"
  end
  
  get '/gems/*' do
    filename = params[:splat].join('/')
    gem_path = public_path.join('gems', filename)

    unless gem_path.exist?
      download_gem "#{options.source}/gems/#{filename}", gem_path
      Gem::Indexer.new(options.public).generate_index
    end
    
    send_file gem_path
  end

  get "/*" do
    path = params[:splat].join("/")
    upstream_url = options.source + "/" + path
    tmpfile = tmp_path_for(path)
    
    Net::HTTP.get_response(URI.parse(upstream_url)) do |res| 
      case res
      when Net::HTTPSuccess
        File.open(tmpfile, "wb") do |out|
          res.read_body {|chunk| out.write(chunk) }
        end
      else
        raise Sinatra::NotFound, path
      end
    end
    send_file tmpfile
  end
  
  not_found do
    "\n"
  end

  private
  def public_path
    @public_path ||= Pathname.new(options.public)
  end

  def download_gem(url, local_path)
    Net::HTTP.get_response(URI.parse(url)) do |res| 
      case res
      when Net::HTTPSuccess
        local_path.open("wb") do |f|
          res.read_body {|chunk| f.write(chunk) }
        end
      when Net::HTTPRedirection
        download_gem res['location'], local_path 
      else
        raise Sinatra::NotFound, filename
      end
    end
  end
    
  def tmp_path_for(path)
    tmpfile = Pathname.new File.join(tmp_path, path)
    unless tmpfile.dirname.exist?
      tmpfile.dirname.mkpath
    end
    tmpfile
  end
  
  def tmp_path
    # There is a bug in jruby with regard to renaming files
    # across devices. Make sure the tmp dir is on the same
    # dir as the gem files.
    if RUBY_PLATFORM =~ /java/
      tmp_dir = File.join(options.public, 'tmp')
      Dir.mkdir tmp_dir unless File.exist?(tmp_dir)
      ENV["TMPDIR"] = tmp_dir
    end
    Dir.tmpdir
  end
  alias set_tmp_path tmp_path
  
end

