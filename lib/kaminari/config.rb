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
    config_accessor :default_per_page
    config_accessor :window
    config_accessor :outer_window
    config_accessor :left
    config_accessor :right
    config_accessor :param_name

    def param_name
      if block_given?
        yield
      elsif config.param_name.respond_to? :call
        config.param_name.call()
      else
        config.param_name 
      end
    end
  end

  # this is ugly. why can't we pass the default value to config_accessor...?
  configure do |config|
    config.default_per_page = 25
    config.window = 4
    config.outer_window = 0
    config.left = 0
    config.right = 0
    config.param_name = :page
  end
end
