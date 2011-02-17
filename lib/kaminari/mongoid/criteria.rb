module Kaminari
  module Mongoid
    module Criteria
      extend ActiveSupport::Concern

      included do
        # Fetch the values at the specified page number
        #   Model.order_by(:name.asc).page(5)
        def page(num)
          limit(@klass.default_per_page).offset(@klass.default_per_page * ([num.to_i, 1].max - 1))
        end

        # Specify the <tt>per_page</tt> value for the preceding <tt>page</tt> scope
        #   Model.order_by(:name.asc).page(3).per(10)
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
    end
  end
end
