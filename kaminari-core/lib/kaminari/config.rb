# frozen_string_literal: true
require 'active_support/configurable'

module Kaminari
  # Configures global settings for Kaminari
  #   Kaminari.configure do |config|
  #     config.default_per_page = 10
  #   end
  include ActiveSupport::Configurable

  config.instance_eval do
    self.default_per_page = 25
    self.max_per_page = nil
    self.window = 4
    self.outer_window = 0
    self.left = 0
    self.right = 0
    self.page_method_name = :page
    self.param_name = :page
    self.max_pages = nil
    self.params_on_first_page = false

    # If param_name was given as a callable object, call it when returning
    def param_name
      self[:param_name].respond_to?(:call) ? self[:param_name].call : self[:param_name]
    end
  end
end
