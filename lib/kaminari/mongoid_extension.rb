module Kaminari
  module MongoidExtension
    DEFAULT_PER_PAGE = 25

    module Criteria
      extend ActiveSupport::Concern

      included do
        delegate :page, :per, :num_pages, :current_page, :limit_value, :to => '@klass'
      end
    end

    module Document
      extend ActiveSupport::Concern

      included do
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
              limit(n).offset(options[:skip] / options[:limit] * n)
            end
          end

          # Total number of pages
          def num_pages
            (count.to_f / options[:limit]).ceil
          end

          # Current page number
          def current_page
            (options[:skip] / options[:limit]) + 1
          end

          def limit_value
            options[:limit]
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
          @_default_per_page || Kaminari::MongoidExtension::DEFAULT_PER_PAGE
        end
      end
    end
  end
end
