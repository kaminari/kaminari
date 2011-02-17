module Kaminari
  module ActiveRecordExtension
    extend ActiveSupport::Concern
    DEFAULT_PER_PAGE = 25

    included do
      def self.inherited(kls) #:nodoc:
        # TERRIBLE HORRIBLE NO GOOD VERY BAD HACK: inheritable_attributes is not yet set here on AR 3.0
        unless kls.default_scoping
          new_inheritable_attributes = Hash[inheritable_attributes.map do |key, value|
            [key, value.duplicable? ? value.dup : value]
          end]
          kls.instance_variable_set('@inheritable_attributes', new_inheritable_attributes)
        end

        kls.class_eval do
          # Fetch the values at the specified page number
          #   Model.page(5)
          scope :page, lambda {|num|
            limit(default_per_page).offset(default_per_page * ([num.to_i, 1].max - 1))
          } do
            # Specify the <tt>per_page</tt> value for the preceding <tt>page</tt> scope
            #   Model.page(3).per(10)
            def per(num)
              if (n = num.to_i) <= 0
                self
              else
                limit(n).offset(offset_value / limit_value * n)
              end
            end

            # Total number of pages
            def num_pages
              (except(:offset, :limit).count.to_f / limit_value).ceil
            end

            # Current page number
            def current_page
              (offset_value / limit_value) + 1
            end
          end

          # Overrides the default per_page value per model
          #   class Article < ActiveRecord::Base
          #     paginates_per 10
          #   end
          def self.paginates_per(val)
            @_default_per_page = val
          end

          # This model's default per_page value
          # returns 25 unless explicitly overridden via <tt>paginates_per</tt>
          def self.default_per_page
            @_default_per_page || Kaminari::ActiveRecordExtension::DEFAULT_PER_PAGE
          end
        end
      end
    end
  end
end
