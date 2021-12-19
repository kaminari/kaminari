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

# Monkey-patching test-unit-rails not to raise NameError from triple-nested sub_test_case
ActionView::TestCase.class_eval do
  class << self
    def sub_test_case(name, &block)
      parent_test_case = self
      sub_test_case = Class.new(self) do
        singleton_class = class << self; self; end
        singleton_class.__send__(:define_method, :name) do
          [parent_test_case.name, name].compact.join("::")
        end
        singleton_class.__send__(:define_method, :default_helper_module!) do
          begin
            super()
          rescue NameError
            # Anonymous classes generated via sub_test_case may not always follow Ruby module name convention
          end
        end
      end
      sub_test_case.class_eval(&block)
      sub_test_case
    end
  end
end
