module Kaminari
  module ActiveRecord
    extend ActiveSupport::Concern
    PER_PAGE = 25

    included do
      def self.inherited(kls)
        # TERRIBLE HORRIBLE NO GOOD VERY BAD HACK: inheritable_attributes is not yet set here on AR 3.0
        unless kls.default_scoping
          new_inheritable_attributes = Hash[inheritable_attributes.map do |key, value|
            [key, value.duplicable? ? value.dup : value]
          end]
          kls.instance_variable_set('@inheritable_attributes', new_inheritable_attributes)
        end
        kls.class_eval do
          # page(5)
          scope :page, lambda {|num|
            offset(PER_PAGE * ([num.to_i, 1].max - 1)).limit(PER_PAGE)
          } do
            # page(3).per(10)
            def per(num)
              offset(offset_value / limit_value * num).limit(num)
            end

            def num_pages
              (except(:offset, :limit).count.to_f / limit_value).ceil
            end

            def current_page
              (offset_value / limit_value) + 1
            end
          end
        end
      end
    end
  end
end
