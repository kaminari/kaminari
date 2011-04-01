module Kaminari
  module ActiveRecordRelationMethods
    extend ActiveSupport::Concern
    module InstanceMethods
      def total_count #:nodoc:
        if distinct_column_name.nil?
          c = except(:offset, :limit).count
        else  
          c = except(:offset, :limit).count(distinct_column_name, :distinct => true)
        end
        # .group returns an OrderdHash that responds to #count
        c.respond_to?(:count) ? c.count : c
      end
      
      # Get the column name used in distinct query.
      # This could have been set on the Model class, or the ActiveRecord::Relation 
      def distinct_column_name
        @distinct_column || distinct_column
      end
    end
  end
end
