require File.dirname(__FILE__) + '/spec_helper'
require 'rack/test'
require 'sham_rack'

ProxyApp.set :environment, :test

describe ProxyApp do
  include Rack::Test::Methods

  def app
    ProxyApp
  end
  
  before(:each) do
    # HACK OSX /private/tmp, yanked from rubygems RubyGemTestCase
    tmpdir = nil
    Dir.chdir Dir.tmpdir do tmpdir = Dir.pwd end 
    
    @tmpdir = File.join tmpdir, "test_rubygems-proxy_server_#{$$}"
    @tmpdir.untaint
    @gemsdir = File.join @tmpdir, 'gems'

    FileUtils.mkdir_p @gemsdir
            
    @gem_source = 'http://www.test.host'
    @gem_indexer = mock(:gem_indexer)
    
    ProxyApp.set :source, @gem_source
    ProxyApp.set :public, @tmpdir
    ProxyApp.set :mock_gem_indexer, @gem_indexer    
  end
  
  after(:each) do
    FileUtils.rm_rf @tmpdir
  end
  
  context '/gems/*' do
    before(:each) do
      
      @gem_source = ShamRack.at('www.test.host').sinatra do
        def request_count; @@request_count end
        @@request_count = 0

        get '/gems/not_found' do
          not_found
        end
        
        get '/gems/redirect-0.1.0.gem' do
          redirect 'http://www.test.host/gems/from-redirect-0.1.0.gem'
        end
        
        get '/gems/*' do
          @@request_count += 1
          "gem: #{File.join params[:splat]}"
        end
      end
      
    end
    
    it 'should download the gem from the upstream server' do
      @gem_indexer.should_receive(:generate_index)
      
      get '/gems/test-gem-0.1.0.gem'
      last_response.should be_ok
      last_response.body.should == 'gem: test-gem-0.1.0.gem'
    end

    it "should write the gem file to the 'gems' directory" do
      @gem_indexer.should_receive(:generate_index)
      
      get '/gems/test-gem-0.1.0.gem'
      File.should exist(File.join(@tmpdir, 'gems/test-gem-0.1.0.gem'))
    end

    it "should not download the gem a second time" do
      @gem_indexer.should_receive(:generate_index)
      
      get '/gems/test-gem-0.1.0.gem'
      get '/gems/test-gem-0.1.0.gem'

      @gem_source.request_count.should == 1
    end

    it 'should respond with 404 Not Found when the gem source reports the same' do
      get '/gems/not_found'
      
      last_response.should be_not_found
      last_response.body.should == "\n"
    end
    
    it "should follow a redirect" do
      @gem_indexer.should_receive(:generate_index)
      
      get '/gems/redirect-0.1.0.gem'

      last_response.should be_ok
      last_response.body.should == 'gem: from-redirect-0.1.0.gem'
      File.should exist(File.join(@tmpdir, 'gems/redirect-0.1.0.gem'))
    end
  end

  context '/*' do
    before(:each) do
      ShamRack.at('www.test.host').sinatra do
        get '/not_found' do
          error 404, 'Not Found'
        end
        
        get '/*' do
          "file: #{File.join params[:splat]}"
        end
      end      
    end
    
    it 'should download the file from the upstream server' do
      get '/some/random/file'
      last_response.should be_ok
      last_response.body.should == 'file: some/random/file'
    end

    it "should write the file to the proxy's tmp directory" do
      get '/some/random/file'
      File.should exist(File.join(@tmpdir, 'rubygems-proxy_server-cache/some/random/file'))
    end

    it "should respond with 404 Not Found when the gem source reports the same" do
      get '/not_found'

      last_response.should be_not_found
      last_response.body.should == "\n"
    end
  end

  context '/' do
    it 'reports server info' do
      get '/'
      last_response.should be_ok
      last_response.body.should == <<-EOS
directory: #{@tmpdir}
gem_source: #{@gem_source}
EOS
    end
  end

end

