$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'rubygems_plugin'
require 'spec'
require 'spec/autorun'
require 'mockgemui'

Spec::Runner.configure do |config|
end
