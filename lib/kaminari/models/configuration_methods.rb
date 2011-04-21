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
        @_default_per_page || Kaminari.config.default_per_page
      end
    end
  end
end
