require 'kaminari/models/active_record_relation_methods'

module Kaminari
  module ActiveRecordModelExtension
    extend ActiveSupport::Concern

    included do
      self.send(:include, Kaminari::ConfigurationMethods)
    end

    module ClassMethods
      # Fetch the values at the specified page number
      #   Model.page(5)
      define_method(Kaminari.config.page_method_name) do |num = nil|
        limit(default_per_page).offset(default_per_page * ([num.to_i, 1].max - 1)).extending do
          include Kaminari::ActiveRecordRelationMethods
          include Kaminari::PageScopeMethods
        end
      end
    end
  end
end
