require 'active_support/configurable'

module Kaminari
  # Configures global settings for Kaminari
  #   Kaminari.configure do |config|
  #     config.default_per_page = 10
  #   end
  def self.configure(&block)
    yield @config ||= Kaminari::Configuration.new
  end

  # Global settings for Kaminari
  def self.config
    @config
  end

  # need a Class for 3.0
  class Configuration #:nodoc:
    include ActiveSupport::Configurable
    config_accessor(:default_per_page) { 25 }
    config_accessor(:max_per_page) { nil }
    config_accessor(:window) { 4 }
    config_accessor(:outer_window) { 0 }
    config_accessor(:left) { 0 }
    config_accessor(:right) { 0 }
    config_accessor(:page_method_name) { :page }
    config_accessor(:max_pages) { nil }

    def param_name
      config.param_name.respond_to?(:call) ? config.param_name.call : config.param_name
    end

    # define param_name writer (copied from AS::Configurable)
    writer, line = 'def param_name=(value); config.param_name = value; end', __LINE__
    singleton_class.class_eval writer, __FILE__, line
    class_eval writer, __FILE__, line
  end
end
