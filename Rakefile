require 'rubygems'
require 'rake'

PROXY_SERVER_VERSION = File.read('VERSION')

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rubygems-proxy_server"
    gem.summary = "A gem source proxy."
    gem.description = "A gem source proxy"
    gem.email = "jeremy.burks@gmail.com"
    gem.homepage = "http://github.com/jrun/rubygems-proxy_server"
    gem.authors = ["jrun"]
    gem.add_dependency 'rack', '~> 1.0.1'
    gem.add_dependency "sinatra", "~> 0.9.4"
    gem.add_development_dependency "rspec", "~> 1.2.9"
    gem.add_development_dependency 'rack-test', '~> 0.5.2'
    gem.add_development_dependency 'sham_rack', '~> 1.1.2'
    gem.add_development_dependency 'grancher', '> 0'
    gem.files = FileList['[a-zA-Z]*', 'bin/**/*', 'lib/**/*', 'spec/**/*']
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
task :build => :spec

namespace :gem do
  desc "Build and reinstalls the gem locally"
  task :reinstall do
    Rake::Task[:build].invoke
    if gem_installed?
      system "gem uninstall rubygems-proxy_server"
    end
    system "gem install --no-rdoc --no-ri -l #{File.dirname(__FILE__)}/pkg/rubygems-proxy_server-#{PROXY_SERVER_VERSION}"
  end
end

def gem_installed?
  (system("gem list rubygems-proxy_server -l") || "")  =~
    /rubygems-proxy_server-#{PROXY_SERVER_VERSION}/
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

begin
  require 'grancher/task'
  Grancher::Task.new do |g|
    Rake::Task['yard'].invoke    
    g.branch = 'gh-pages'
    g.push_to = 'origin'
    g.directory 'doc'
  end
rescue LoadError
  task :yardoc do
    abort "publish is not available. In order to run publish, you must: sudo gem install grancher"
  end
end
