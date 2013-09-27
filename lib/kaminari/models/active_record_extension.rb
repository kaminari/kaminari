require 'kaminari/models/active_record_relation_methods'

module Kaminari
  module ActiveRecordExtension
    extend ActiveSupport::Concern
    included do
      # Future subclasses will pick up the model extension
      class << self
        def inherited_with_kaminari(kls) #:nodoc:
          inherited_without_kaminari kls
          add_paging_to_class(kls) if kls.superclass == ActiveRecord::Base
        end
        alias_method_chain :inherited, :kaminari

        private

        # work around https://github.com/rails/rails/issues/10658 by defining a class method
        # instead of using scope to avoid problems with abstract base classes.
        def add_paging_to_class(kls)
          kls.send(:include, Kaminari::ConfigurationMethods)
          kls.class.send(:define_method, Kaminari.config.page_method_name) do |num=0|
            result = limit(default_per_page).offset(default_per_page * ([num.to_i, 1].max - 1))
            result.extend Kaminari::ActiveRecordRelationMethods
            result.extend Kaminari::PageScopeMethods
            result
          end
        end
      end

      # Existing subclasses pick up the model extension as well
      self.descendants.each do |kls|
        add_paging_to_class(kls) if kls.superclass == ActiveRecord::Base
      end
    end
  end
end
