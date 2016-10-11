require 'active_support/configurable'

module Kaminari
  # Configures global settings for Kaminari
  #   Kaminari.configure do |config|
  #     config.default_per_page = 10
  #   end
  include ActiveSupport::Configurable

  config_accessor(:default_per_page, instance_accessor: false) { 25 }
  config_accessor(:max_per_page, instance_accessor: false)
  config_accessor(:window, instance_accessor: false) { 4 }
  config_accessor(:outer_window, instance_accessor: false) { 0 }
  config_accessor(:left, instance_accessor: false) { 0 }
  config_accessor(:right, instance_accessor: false) { 0 }
  config_accessor(:page_method_name, instance_accessor: false) { :page }
  config_accessor(:param_name, instance_accessor: false) { :page }
  config_accessor(:max_pages, instance_accessor: false)
  config_accessor(:params_on_first_page, instance_accessor: false) { false }

  # If param_name was given as a callable object, call it when returning
  config.undef_method :param_name
  def config.param_name
    self[:param_name].respond_to?(:call) ? self[:param_name].call : self[:param_name]
  end
end
