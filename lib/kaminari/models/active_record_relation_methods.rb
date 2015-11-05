module Kaminari
  module ActiveRecordRelationMethods
    def entry_name
      model_name.human.downcase
    end

    def reset #:nodoc:
      @total_count = nil
      super
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
        # query to construct the count. This will cause an exception.
        # Some group_by counts return hashes, which cannot be used to calculate the number of
        # groups.
        # In both these cases, using a sub-query to count groups resolves the issue.
        sql = c.to_sql.downcase
        is_group = sql =~ /\s(group\sby|having)\s/
        if is_group
          if ActiveRecord::VERSION::STRING >= '3.1'
            sm = Arel::SelectManager.new c.engine
            select_value = "count(*) as count"
            counting_subquery = sm.project(select_value).from(c.arel.as("subquery_for_count"))
            connection.select_one(counting_subquery)['count']
          else
            # With ActiveRecord 3 fall back to string interpolation
            c = self.connection.execute("select count(*) as subquery_count " +
                                        "from (#{c.to_sql}) as subquery_for_count").first
            if c.is_a?(Hash) || c.is_a?(ActiveSupport::OrderedHash)
              c['subquery_count']
            else
              c.first.to_i
            end
          end
        else
          c.respond_to?(:count) ? c.count(*args) : c
        end
      end
    end
  end
end
