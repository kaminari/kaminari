require 'active_support/configurable'

module Kaminari
  # Configures global settings for Kaminari
  #   Kaminari.configure do |config|
  #     config.default_per_page = 10
  #   end
  include ActiveSupport::Configurable

  config_accessor(:default_per_page) { 25 }
  config_accessor(:max_per_page)
  config_accessor(:window) { 4 }
  config_accessor(:outer_window) { 0 }
  config_accessor(:left) { 0 }
  config_accessor(:right) { 0 }
  config_accessor(:page_method_name) { :page }
  config_accessor(:param_name) { :page }
  config_accessor(:max_pages)
  config_accessor(:params_on_first_page) { false }

  # If param_name was given as a callable object, call it when returning
  config.undef_method :param_name
  def config.param_name
    self[:param_name].respond_to?(:call) ? self[:param_name].call : self[:param_name]
  end
end
