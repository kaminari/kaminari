module Kaminari
  module Mongoid
    extend ActiveSupport::Concern
    DEFAULT_PER_PAGE = 25

    included do
      # page(5)
      scope :page, lambda {|num|
        per_page = @_default_per_page || Kaminari::Mongoid::DEFAULT_PER_PAGE
        limit(per_page).offset(per_page * ([num.to_i, 1].max - 1))
      } do
        # page(3).per(10)
        def per(num)
          limit(num).offset(options[:skip] / options[:limit] * num)
        end

        def num_pages
          (count.to_f / options[:limit]).ceil
        end

        def current_page
          (options[:skip] / options[:limit]) + 1
        end

        def limit_value
          options[:limit]
        end
      end

      # overrides the default per_page value per model
      #   class Article < ActiveRecord::Base
      #     paginates_per 10
      #   end
      def self.paginates_per(val)
        @_default_per_page = val
      end
    end
  end
end
