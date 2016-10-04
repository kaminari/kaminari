module Kaminari
  module ConfigurationMethods
    extend ActiveSupport::Concern
    module ClassMethods
      # Overrides the default +per_page+ value per model
      #   class Article < ActiveRecord::Base
      #     paginates_per 10
      #   end
      def paginates_per(val)
        @_default_per_page = val
      end

      # This model's default +per_page+ value
      # returns +default_per_page+ value unless explicitly overridden via <tt>paginates_per</tt>
      def default_per_page
        (defined?(@_default_per_page) && @_default_per_page) || Kaminari.config.default_per_page
      end

      # Overrides the max +per_page+ value per model
      #   class Article < ActiveRecord::Base
      #     max_paginates_per 100
      #   end
      def max_paginates_per(val)
        @_max_per_page = val
      end

      # This model's max +per_page+ value
      # returns +max_per_page+ value unless explicitly overridden via <tt>max_paginates_per</tt>
      def max_per_page
        (defined?(@_max_per_page) && @_max_per_page) || Kaminari.config.max_per_page
      end

      # Overrides the max_pages value per model
      #   class Article < ActiveRecord::Base
      #     max_pages_per 100
      #   end
      def max_pages_per(val)
        @_max_pages = val
      end

      # This model's max_pages value
      # returns max_pages value unless explicitly overridden via <tt>max_pages_per</tt>
      def max_pages
        (defined?(@_max_pages) && @_max_pages) || Kaminari.config.max_pages
      end
    end
  end
end
