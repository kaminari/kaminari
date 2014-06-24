module Kaminari
  module ActiveRecordRelationMethods
    # a workaround for AR 3.0.x that returns 0 for #count when page > 1
    # if +limit_value+ is specified, load all the records and count them
    if ActiveRecord::VERSION::STRING < '3.1'
      def count(column_name = nil, options = {}) #:nodoc:
        limit_value && !options[:distinct] ? length : super(column_name, options)
      end
    end

    def entry_name
      model_name.human.downcase
    end

    def total_count(column_name = :all, options = {}) #:nodoc:
      # #count overrides the #select which could include generated columns referenced in #order, so skip #order here, where it's irrelevant to the result anyway
      @total_count ||= begin
        c = except(:offset, :limit, :order)

        # Remove includes only if they are irrelevant
        c = c.except(:includes) unless references_eager_loaded_tables?

        # Rails 4.1 removes the `options` argument from AR::Relation#count
        args = [column_name]
        args << options if ActiveRecord::VERSION::STRING < '4.1.0'

        # If group_by is used alongside column aliases, 'count' will destroy the select part of the
        # query to construct the count. This means aliases will be used without being defined.
        # In this case we want to construct a query with a count running on the relation
        # as a sub-query
        count_sql = c.to_sql.downcase
        group_with_alias = count_sql.include?(" group by ") && count_sql.include?(" as ")
        if group_with_alias
          c = self.connection.execute("select count(*) as full_count from (#{c.to_sql}) as rel").first
          if c.is_a?(Hash) || c.is_a?(ActiveSupport::OrderedHash)
            c['full_count']
          else
            c.first.to_i
          end
        else
          # .group returns an OrderdHash that responds to #count
          c = c.count(*args)
          if c.is_a?(Hash) || c.is_a?(ActiveSupport::OrderedHash)
            c.count
          else
            c.respond_to?(:count) ? c.count(*args) : c
          end
        end
      end
    end
  end
end
