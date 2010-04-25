require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "doctorup"
    gem.summary = %Q{ (BETA) syntax highlighting made easy }
    gem.description = %Q{(BETA) If you use textile and want to to add syntax highlighting for code blocks then doctorup is for you!  Uses a simple DSL that makes writing documentation and turorials a snap! }
    gem.email = "billy@codesponge.com"
    gem.homepage = "http://github.com/codesponge/doctorup"
    gem.authors = ["codesponge"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    ['RedCloth','hpricot'].each do |g|
      gem.add_dependency g
    end

    #either or both of these gems will be required in some version
    #['coderay','uv']

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

#Clean stuff
namespace :clean do
  task :develop_logs do
    puts "Cleaning develop logs"
    Dir.glob("develop_logs/*.log").each do |f|
      puts "\tEmptying #{f}."
      File.open(f,'w') {|f| f << '' }
    end
  end
end
task :test => :check_dependencies

task :default => :test
require 'hanna/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "doctorup #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('LICENSE')
  rdoc.options += [
    '-SHN'
    ]
end
