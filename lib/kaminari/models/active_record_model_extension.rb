require 'kaminari/models/active_record_relation_methods'
require 'kaminari/models/page_extensions'

module Kaminari
  module ActiveRecordModelExtension
    extend ActiveSupport::Concern

    included do
      self.send(:include, Kaminari::ConfigurationMethods)
      self.send(:extend, Kaminari::PageExtensions)

      # Fetch the values at the specified page number
      #   Model.page(5)
      self.scope Kaminari.config.page_method_name, Proc.new {|num|
        limit(default_per_page).offset(calculate_offset(num))
      } do
        include Kaminari::ActiveRecordRelationMethods
        include Kaminari::PageScopeMethods
      end
    end

  end
end
