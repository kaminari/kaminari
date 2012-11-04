require 'kaminari/models/active_record_relation_methods'

module Kaminari
  module ActiveRecordModelExtension
    extend ActiveSupport::Concern

    included do
      self.send(:include, Kaminari::ConfigurationMethods)
      self.send(:extend, ClassMethods)

      # Fetch the values at the specified page number
      #   Model.page(5)
      self.scope Kaminari.config.page_method_name, Proc.new {|num|
        limit(default_per_page).offset(calculate_offset(num))
      } do
        include Kaminari::ActiveRecordRelationMethods
        include Kaminari::PageScopeMethods
      end
    end

    module ClassMethods
      def calculate_offset(num)
        num = default_per_page * ([num.to_i, 1].max - 1)
        goto_page = Kaminari.config.out_of_range

        return 0 if goto_page == :first && out_of_range?(num)
        return scoped.count - default_per_page if goto_page == :last && out_of_range?(num)
        num
      end

      def out_of_range?(num)
        num + 1 > scoped.count
      end
    end

  end
end
