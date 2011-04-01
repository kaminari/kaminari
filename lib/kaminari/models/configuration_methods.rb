module Kaminari
  module ConfigurationMethods
    extend ActiveSupport::Concern
    module ClassMethods
      # Overrides the default per_page value per model
      #   class Article < ActiveRecord::Base
      #     paginates_per 10
      #   end
      def paginates_per(val)
        @_default_per_page = val
      end

      # This model's default per_page value
      # returns 25 unless explicitly overridden via <tt>paginates_per</tt>
      def default_per_page
        @_default_per_page || Kaminari::DEFAULT_PER_PAGE
      end
      
      # Set the name of the column to use during .count()
      # Setting this will cause call to count to use: count(:id, :distinct => true) for all the Models paged queries. 
      # Example:
      #   class User < ActiveRecord::Base
      #     use_distinct :id
      #   end
      def use_distinct(column)
        @distinct_column = column
      end
      
      # Returns the distinct column name set on the Model, or nil if not using distinct
      def distinct_column
        @distinct_column
      end
    end
  end
end
