require File.join(File.dirname(__FILE__), 'active_record_relation_methods')
module Kaminari
  module ActiveRecordExtension
    extend ActiveSupport::Concern
    included do
      def self.inherited(kls) #:nodoc:
        # TERRIBLE HORRIBLE NO GOOD VERY BAD HACK: inheritable_attributes is not yet set here on AR 3.0
        # => What was the purpose of this hack ? All tests are green without it...
        # => Is it for inherit @_default_per_page attribute between models ? If so, using class_attribute might do the trick
        unless kls.default_scopes.empty?
          new_inheritable_attributes = Hash[inheritable_attributes.map do |key, value|
            [key, value.duplicable? ? value.dup : value]
          end]
          kls.instance_variable_set('@inheritable_attributes', new_inheritable_attributes)
        end

        kls.class_eval do
          include Kaminari::ConfigurationMethods

          # Fetch the values at the specified page number
          #   Model.page(5)
          def self.page(num=nil)
            limit(default_per_page).offset(default_per_page * ([num.to_i, 1].max - 1)).extending  do
              include Kaminari::ActiveRecordRelationMethods
              include Kaminari::PageScopeMethods
            end
          end
        end

        super
      end
    end
  end
end
