# encoding: utf-8

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => "spec:all"

namespace :spec do
  %w(active_record_edge active_record_40 active_record_41 active_record_42 active_record_32 active_record_31 active_record_30 data_mapper_12 mongoid_40 mongoid_31 mongoid_30 mongoid_24 mongo_mapper sinatra_13 sinatra_14).each do |gemfile|
    desc "Run Tests against #{gemfile}"
    task gemfile do
      sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle --quiet"
      sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle exec rake -t spec"
    end
  end

  desc "Run Tests against all ORMs"
  task :all do
    %w(active_record_edge active_record_40 active_record_41 active_record_42 active_record_32 active_record_31 active_record_30 data_mapper_12 mongoid_40 mongoid_31 mongoid_30 mongoid_24 mongo_mapper sinatra_13 sinatra_14).each do |gemfile|
      sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle --quiet"
      sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle exec rake spec"
    end
  end
end

begin
  require 'rdoc/task'

  Rake::RDocTask.new do |rdoc|
    require 'kaminari/version'

    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = "kaminari #{Kaminari::VERSION}"
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('lib/**/*.rb')
  end
rescue LoadError
  puts 'RDocTask is not supported on this VM and platform combination.'
end
