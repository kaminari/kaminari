# frozen_string_literal: true
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(Gem.loaded_specs['kaminari-core'].gem_dir, 'spec'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rails'
require 'active_record'

require 'bundler/setup'
Bundler.require

require 'capybara/rspec'
require 'database_cleaner'

# Simulate a gem providing a subclass of ActiveRecord::Base before the Railtie is loaded.
require 'fake_gem'

require 'fake_app/rails_app'

require 'rspec/rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.join(Gem.loaded_specs['kaminari-core'].gem_dir, 'spec')}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rr
  config.filter_run_excluding :generator_spec => true if !ENV['GENERATOR_SPEC']
end
