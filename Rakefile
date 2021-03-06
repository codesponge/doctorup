require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "doctorup"
    gem.summary = %Q{ (BETA) syntax highlighting made easy }
    gem.description = %Q{(BETA) If you use textile and want to to add syntax highlighting for code blocks then doctorup is for you!  Uses a simple DSL that makes writing documentation and turorials a snap! }
    gem.email = "billy@codesponge.com"
    gem.homepage = "http://codesponge.github.com/doctorup/"
    gem.authors = ["codesponge"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    
    ['RedCloth','hpricot'].each do |g|
      gem.add_dependency g
    end
    # the 'uv' gem is required if ruby version 1.8.6 or 1.8.7
    # the 'uv' gem is required if ruby version 1.9.x
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


begin
require 'yard'
YARD::Rake::YardocTask.new do |yard|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  #system("~/bin/doctorup_cs README.textile > README.html")

  yard.options += ['--files','LICENSE']
  yard.options += ['--title',"DoctorUp #{version}"]
#  yard.options += ['--markup',"textile"]
  yard.options += ['--protected']
  yard.options += ['--readme','README.html']
#  yard.options += ['--files','docs/*.html']
  yard.after = lambda {
        puts "Syncing up images"
         system("cp -vR docs/images/ doc/images/")
    
            }
end
rescue
  "Install yard for generating complete documentation"
end

desc "Create Documentation (using YARD)"
task :doc => :yard


=begin
#Assuming master is clean!!
git checkout documentation
git merge --commit -m 'building docs' master
rake yard
# add other stuff or further process doc/
git add .
git commit -m 'updated documentation'
git checkout gh-pages
git checkout documentation "doc/"
=end

namespace :doc do
  desc "Switch branch,build docs, push up to gh-pages"
  task :git_pages do
  cmd = <<-EOCMD
  rake yard && \
  git add . && \
  git stash && \
  git checkout gh-pages && \
  git stash pop && \
  git add . && \
  git commit -m 'update gh-pages docs/' && \
  git push github gh-pages && \
  git checkout master
  EOCMD

    #require 'facets'
    #system(cmd) if ask("Are You sure?  master is clean and all that? [Yn]").to_b
    puts "Command Disabled due to merge conflicts (needs a re-write)"
  end

end


# require 'hanna/rdoctask'
# Rake::RDocTask.new do |rdoc|
#   version = File.exist?('VERSION') ? File.read('VERSION') : ""
# 
#   rdoc.rdoc_dir = 'rdoc'
#   rdoc.title = "doctorup #{version}"
#   rdoc.rdoc_files.include('README*')
#   rdoc.rdoc_files.include('lib/**/*.rb')
#   rdoc.rdoc_files.include('LICENSE')
#   rdoc.options += [
#     '-SHN'
#     ]
# end
