require File.dirname(__FILE__) + '/spec_helper'

describe Gem::Commands::ProxyServerCommand do
  include Gem::DefaultUserInteraction
  
  before(:each) do
    ProxyApp.stub!(:run!)
    @ui = MockGemUi.new    
    @cmd = Gem::Commands::ProxyServerCommand.new
  end

  context 'short options' do
    it '-d BASEDIR' do
      @cmd.handle_options ['-d', '/tmp/rubygems-proxy-server/gems']
      @cmd.options[:directory].should == '/tmp/rubygems-proxy-server/gems'
    end
    
    it '-s URL' do
      @cmd.handle_options ['-s', 'http://test.host/gems']
      @cmd.options[:remote_source].should == 'http://test.host/gems'
    end
    
    it '-p PORT'  do
      @cmd.handle_options ['-p', '6688']
      @cmd.options[:port].should == 6688
    end
  end
  
  context '#execute' do
    it "should report an error when the gems directory option is not given" do
      use_ui @ui do
        lambda do
          @cmd.execute
        end.should raise_error(MockGemUi::TermError)
      end
      @ui.error.should == "ERROR:  #{Gem::Commands::ProxyServerCommand::NIL_DIR_MSG}\n"
    end
    
    it "should report an error when the gems directory does not exist" do
      @cmd.handle_options ['--directory', '/tmp/does/not/exist']
      use_ui @ui do
        lambda do
          @cmd.execute
        end.should raise_error(MockGemUi::TermError)
      end
      @ui.error.should =~ /unknown directory name/
    end

    context 'with valid options' do
      before(:each) do
        @dir = '/tmp/rubygems-proxy-server/test'
        
        File.stub!(:exist?).and_return(true)
        File.stub!(:directory?).and_return(true)
      end
      
      it "should run the ProxyApp with defaults" do
        port = Gem::Commands::ProxyServerCommand::PROXY_DEFAULT_PORT
        gem_source = Gem::Commands::ProxyServerCommand::PROXY_DEFAULT_GEM_SOURCE
        
        @cmd.handle_options ['--directory', @dir]

        ProxyApp.should_receive(:run!).with(:port => port,
                                            :source => gem_source,
                                            :public => @dir)

        use_ui @ui do
          @cmd.execute
        end
      end

      it 'should run the ProxyApp with the given port' do
        gem_source = Gem::Commands::ProxyServerCommand::PROXY_DEFAULT_GEM_SOURCE        

        @cmd.handle_options ['--directory', @dir, '--port', '7799']
        
        ProxyApp.should_receive(:run!).with(:port => 7799,
                                            :source => gem_source,
                                            :public => @dir)

        use_ui @ui do
          @cmd.execute
        end
      end

      it 'should run the ProxyApp with the given gem source' do
        gem_source = 'http://test.host/gems'

        @cmd.handle_options ['--directory', @dir, '--source', gem_source]
        
        ProxyApp.should_receive(:run!).with(:port => Gem::Commands::ProxyServerCommand::PROXY_DEFAULT_PORT,
                                            :source => gem_source,
                                            :public => @dir)

        use_ui @ui do
          @cmd.execute
        end
      end
      
      
    end
    
  end
end
