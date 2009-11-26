require File.dirname(__FILE__) + '/spec_helper'
require 'rack/test'

ProxyApp.set :environment, :test

describe ProxyApp do
  include Rack::Test::Methods

  def app
    ProxyApp
  end
  
  before(:each) do
    ProxyApp.set :public, '/tmp/rubygems-proxy_server'
    ProxyApp.set :source, 'http://test.host/gems'
  end
  
  it '/ reports server info' do    
    get '/'
    last_response.should be_ok
    last_response.body.should == <<-EOS
directory: /tmp/rubygems-proxy_server
gem_source: http://test.host/gems
EOS
  end
end

