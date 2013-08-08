require 'kaminari/models/active_record_relation_methods'

module Kaminari
  module ActiveRecordModelExtension
    extend ActiveSupport::Concern

    included do
      self.send(:include, Kaminari::ConfigurationMethods)
     
      class << self
        # Fetch the values at the specified page number
        #   Model.page(5)
        define_method Kaminari.config.page_method_name do |*args|
          raise ArgumentError.new("wrong number of arguments(#{args.size} for 1)") if args.size > 1
          num = args.first
          self.
            limit(default_per_page).
            offset(default_per_page * ([num.to_i, 1].max - 1)).
            extending(Kaminari::ActiveRecordRelationMethods).
            extending(Kaminari::PageScopeMethods)
        end       
      end
    end
  end
end
