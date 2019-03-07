# frozen_string_literal: true

require 'active_support/concern'

module Kaminari
  module ConfigurationMethods #:nodoc:
    extend ActiveSupport::Concern
    module ClassMethods #:nodoc:

      # Overrides the default +cursor_limit+ value per model
      #   class Article < ActiveRecord::Base
      #     cursor_paginates_limit 10
      #   end
      def cursor_paginates_limit(val)
        @_default_cursor_limit = val
      end

      # This model's default +cursor_limit+ value
      # returns +default_cursor_limit+ value unless explicitly overridden via <tt>cursor_paginates_limit</tt>
      def default_cursor_limit
        (defined?(@_default_cursor_limit) && @_default_cursor_limit) || Kaminari.config.default_cursor_limit
      end

      # Overrides the max +per_page+ value per model
      #   class Article < ActiveRecord::Base
      #     max_paginates_per 100
      #   end
      def max_cursor_limit(val)
        @_cursor_max_limit = val
      end

      # This model's max +cursor_max_limit+ value
      # returns +cursor_max_limit+ value unless explicitly overridden via <tt>max_cursor_limit</tt>
      def cursor_max_limit
        (defined?(@_cursor_max_limit) && @_cursor_max_limit) || Kaminari.config.cursor_max_limit
      end

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

      # Overrides the max_pages value per model when a value is given
      #   class Article < ActiveRecord::Base
      #     max_pages 100
      #   end
      #
      # Also returns this model's max_pages value (globally configured
      # +max_pages+ value unless explicitly overridden) when no value is given
      def max_pages(val = :none)
        if val == :none
          # getter
          (defined?(@_max_pages) && @_max_pages) || Kaminari.config.max_pages
        else
          # setter
          @_max_pages = val
        end
      end

      def max_pages_per(val)
        ActiveSupport::Deprecation.warn 'max_pages_per is deprecated. Use max_pages instead.'
        max_pages val
      end
    end
  end
end
