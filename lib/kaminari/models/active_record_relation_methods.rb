module Kaminari
  module ActiveRecordRelationMethods
    # a workaround for AR 3.0.x that returns 0 for #count when page > 1
    # if +limit_value+ is specified, load all the records and count them
    if ActiveRecord::VERSION::STRING < '3.1'
      def count(column_name = nil, options = {}) #:nodoc:
        limit_value ? length : super(column_name, options)
      end
    end

    def total_count(column_name = :all, options = {}) #:nodoc:
      # #count overrides the #select which could include generated columns referenced in #order, so skip #order here, where it's irrelevant to the result anyway
      @total_count ||= begin
        relation = except(:offset, :limit, :order)

        # Remove includes only if they are irrelevant
        relation = relation.except(:includes) unless references_eager_loaded_tables?

        # .group returns an OrderdHash that responds to #count
        c = relation.count(column_name, options)

        if c.is_a?(Hash) || c.is_a?(ActiveSupport::OrderedHash)
          sm = Arel::SelectManager.new relation.engine
          select_value = "count(*) as count"
          counting_subquery = sm.project(select_value).from(relation.arel.as("subquery_for_count"))
          connection.select_one(counting_subquery)['count']
        else
          c.respond_to?(:count) ? c.count(column_name, options) : c
        end
      end
    end
  end
end
