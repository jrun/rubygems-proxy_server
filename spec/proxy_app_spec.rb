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
        
    ShamRack.at('www.test.host').sinatra do
      get '/gems/*' do
        "gem: #{File.join params[:splat]}"
      end
      
      get '/*' do
        "file: #{File.join params[:splat]}"
      end
    end
    
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
  end

  context '/*' do
    it 'should download teh file from the upstream server' do
      get '/some/random/file'
      last_response.should be_ok
      last_response.body.should == 'file: some/random/file'
    end

    it "should write the file to the proxy's tmp directory" do
      get '/some/random/file'
      File.should exist(File.join(Dir.tmpdir, 'some/random/file'))
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

