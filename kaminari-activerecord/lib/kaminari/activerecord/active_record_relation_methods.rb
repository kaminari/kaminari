# frozen_string_literal: true
module Kaminari
  module ActiveRecordRelationMethods
    def entry_name(options = {})
      default = options[:count] == 1 ? model_name.human : model_name.human.pluralize
      model_name.human(options.reverse_merge(default: default))
    end

    def reset #:nodoc:
      @total_count = nil
      super
    end

    def total_count(column_name = :all, _options = nil) #:nodoc:
      return @total_count if defined?(@total_count) && @total_count

      # There are some cases that total count can be deduced from loaded records
      if loaded?
        # Total count has to be 0 if loaded records are 0
        return @total_count = 0 if (current_page == 1) && @records.empty?
        # Total count is calculatable at the last page
        return @total_count = (current_page - 1) * @_per + @records.length if defined?(@_per) && (@records.length < @_per)
      end

      # #count overrides the #select which could include generated columns referenced in #order, so skip #order here, where it's irrelevant to the result anyway
      c = except(:offset, :limit, :order)
      # Remove includes only if they are irrelevant
      c = c.except(:includes) unless references_eager_loaded_tables?
      # .group returns an OrderedHash that responds to #count
      c = c.count(column_name)
      @total_count = if c.is_a?(Hash) || c.is_a?(ActiveSupport::OrderedHash)
        c.count
      else
        c.respond_to?(:count) ? c.count(column_name) : c
      end
    end

    def without_count
      extend ::Kaminari::PaginatableWithoutCount
    end
  end

  module PaginatableWithoutCount
    def load
      if loaded? || limit_value.nil?
        super
      else
        @values[:limit] = limit_value + 1
        super
        @values[:limit] = limit_value - 1

        if @records.any?
          @records = @records.dup if (frozen = @records.frozen?)
          @_has_next = !!@records.delete_at(limit_value)
          @records.freeze if frozen
        end

        self
      end
    end

    def last_page?
      !out_of_range? && !@_has_next
    end

    def out_of_range?
      @records.empty?
    end
  end
end
