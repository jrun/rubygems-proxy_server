require File.dirname(__FILE__) + '/spec_helper'

#module Gem
#  module DefaultUserInteraction
#    @ui = MockGemUi.new
#  end
#end

describe Gem::Commands::ProxyServerCommand do
  include Gem::DefaultUserInteraction
  
  before(:each) do
    ProxyApp.stub!(:run!)
    @ui = MockGemUi.new    
    @cmd = Gem::Commands::ProxyServerCommand.new
  end

  it "should report an error when the gems directory does not exist" do
    use_ui @ui do
      lambda do
        @cmd.execute
      end.should raise_error(MockGemUi::TermError)
    end
    @ui.error.should == "ERROR:  #{Gem::Commands::ProxyServerCommand::NIL_DIR_MSG}\n"
  end
end
