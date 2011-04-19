# encoding: utf-8

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  require 'kaminari/version'

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "kaminari #{Kaminari::VERSION}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
