# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(Gem.loaded_specs['kaminari-core'].gem_dir, 'test'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

ENV['RAILS_ENV'] ||= 'test'
ENV['DB'] ||= 'sqlite3'

require 'rails'
require 'active_record'

require 'bundler/setup'
Bundler.require

# Simulate a gem providing a subclass of ActiveRecord::Base before the Railtie is loaded.
require 'fake_gem'

require 'fake_app/rails_app'
require 'test/unit/rails/test_help'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.join(Gem.loaded_specs['kaminari-core'].gem_dir, 'test')}/support/**/*.rb"].each {|f| require f}
