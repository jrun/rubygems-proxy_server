require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rubygems-proxy_server"
    gem.summary = "A gem source proxy."
    gem.description = "A gem source proxy"
    gem.email = "jeremy.burks@gmail.com"
    gem.homepage = "http://jrun.github.com/rubygems-proxy_server"
    gem.authors = ["jrun"]
    gem.add_dependency 'rack', '~> 1.0.1'
    gem.add_dependency "sinatra", "~> 0.9.4"
    gem.add_development_dependency "rspec", "~> 1.2.9"
    gem.add_development_dependency 'rack-test', '~> 0.5.2'
    gem.add_development_dependency 'sham_rack', '~> 1.1.2'
    gem.add_development_dependency 'yard', '~> 0.4.0'    
    gem.add_development_dependency 'grancher', '> 0'
    gem.files = FileList['[a-zA-Z]*', 'bin/**/*', 'lib/**/*', 'spec/**/*']

    desc "Install development dependencies."
    task :setup do
      gems = ::Gem::SourceIndex.from_installed_gems
      gem.dependencies.each do |dep|
        if gems.find_name(dep.name, dep.version_requirements).empty?
          puts "Installing dependency: #{dep}"
          system %Q|gem install #{dep.name} -v "#{dep.version_requirements}"  --development|
        end
      end
    end
    
    desc "Build and reinstall the gem locally."
    task :reinstall => :build  do
      version = File.read('VERSION')
      if (system("gem list #{gem.name} -l") || "")  =~ /#{gem.name}-#{version}/
        system "gem uninstall #{gem.name}"
      end
      system "gem install --no-rdoc --no-ri -l pkg/#{gem.name}-#{version}"
    end
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
task :build => [:spec, :yard]

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yard do
    abort "YARD is not available. Run 'rake setup' to install all development dependencies."
  end
end

begin
  require 'grancher/task'
  Grancher::Task.new do |g|
    g.branch = 'gh-pages'
    g.push_to = 'origin'
    g.directory 'doc'
  end
rescue LoadError
  task :publish do
    abort "grancher is not available. Run 'rake setup' to install all development dependencies."
  end
end
