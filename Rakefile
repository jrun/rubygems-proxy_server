require 'rubygems'
require 'rake'

module ProxyServer
  VERSION = File.exist?('VERSION') ? File.read('VERSION') : ""
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rubygems-proxy-server"
    gem.summary = "Conceptually modeled off of maven-proxy"
    gem.description = "See the summary"
    gem.email = "jeremy.burks@gmail.com"
    gem.homepage = "http://github.com/jrun/rubygems-proxy-server"
    gem.authors = ["jrun"]
    gem.add_dependency 'rack', '>= 1.0.1'
    gem.add_dependency "mongrel", ">= 1.1.5"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.files = FileList['[a-zA-Z]*', 'bin/**/*', 'lib/**/*', 'spec/**/*']
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rubygems-proxy-server #{ProxyServer::VERSION}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Build and reinstalls the gem locally"
task :repackage do
  system "rake build"
  if gem_installed?
    system "gem uninstall rubygems-proxy-server"
  end
  system "gem install -l #{File.dirname(__FILE__)}/pkg/rubygems-proxy-server-#{ProxyServer::VERSION}"
end

def gem_installed?
  system "gem list rubygems-proxy-server -l" =~ /rubygems-proxy-server-#{ProxyServer::VERSION}/
end
