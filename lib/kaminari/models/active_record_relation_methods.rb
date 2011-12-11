module Kaminari
  module ActiveRecordRelationMethods
    # a workaround for AR 3.0.x that returns 0 for #count when page > 1
    # if +limit_value+ is specified, load all the records and count them
    if ActiveRecord::VERSION::STRING < '3.1'
      def count #:nodoc:
        limit_value ? length : super
      end
    end

    def total_count #:nodoc:
      # #count overrides the #select which could include generated columns referenced in #order, so skip #order here, where it's irrelevant to the result anyway
      @total_count ||= begin
        c = except(:offset, :limit, :order)
        
        # a workaround for 3.1.beta1 bug. see: https://github.com/rails/rails/issues/406
        c = c.reorder nil
        
        # Remove includes only if they are irrelevant
        c = c.except(:includes) unless references_eager_loaded_tables?
        
        uses_distinct_sql_statement = c.to_sql =~ /DISTINCT/i
        if uses_distinct_sql_statement
          return c.length
        end
          
        # .group returns an OrderdHash that responds to #count
        c = c.count
        c.respond_to?(:count) ? c.count : c
      end
    end
  end
end
