# frozen_string_literal: true

module Kaminari
  # Active Record specific page scope methods implementations
  module ActiveRecordRelationMethods
    # Used for page_entry_info
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
        # Total count is calculable at the last page
        return @total_count = (current_page - 1) * limit_value + @records.length if @records.any? && (@records.length < limit_value)
      end

      # #count overrides the #select which could include generated columns referenced in #order, so skip #order here, where it's irrelevant to the result anyway
      c = except(:offset, :limit, :order)
      # Remove includes only if they are irrelevant
      c = c.except(:includes) unless references_eager_loaded_tables?

      c = c.limit(max_pages * limit_value) if max_pages && max_pages.respond_to?(:*)

      # .group returns an OrderedHash that responds to #count
      c = c.count(column_name)
      @total_count = if c.is_a?(Hash) || c.is_a?(ActiveSupport::OrderedHash)
                       c.count
                     elsif c.respond_to? :count
                       c.count(column_name)
                     else
                       c
                     end
    end

    # Turn this Relation to a "without count mode" Relation.
    # Note that the "without count mode" is supposed to be performant but has a feature limitation.
    #   Pro: paginates without casting an extra SELECT COUNT query
    #   Con: unable to know the total number of records/pages
    def without_count
      extend ::Kaminari::PaginatableWithoutCount
    end
  end

  # A module that makes AR::Relation paginatable without having to cast another SELECT COUNT query
  module PaginatableWithoutCount
    module LimitValueSetter
      # refine PaginatableWithoutCount do  # NOTE: this doesn't work in Ruby < 2.4
      refine ::ActiveRecord::Relation do
        private

        # Update multiple instance variables that hold `limit` to a given value
        def set_limit_value(new_limit)
          @values[:limit] = new_limit

          if @arel
            case @arel.limit.class.name
            when 'Integer', 'Fixnum'
              @arel.limit = new_limit
            when 'ActiveModel::Attribute::WithCastValue'  # comparing by class name because ActiveModel::Attribute::WithCastValue is a private constant
              @arel.limit = build_cast_value 'LIMIT', new_limit
            when 'Arel::Nodes::BindParam'
              if @arel.limit.respond_to?(:value)
                @arel.limit = Arel::Nodes::BindParam.new(@arel.limit.value.with_cast_value(new_limit))
              end
            end
          end
        end
      end
    end
  end
end
# NOTE: ending all modules and reopening again because using has to be called from the toplevel in Ruby 2.0
using Kaminari::PaginatableWithoutCount::LimitValueSetter

module Kaminari
  module PaginatableWithoutCount
    # Overwrite AR::Relation#load to actually load one more record to judge if the page has next page
    # then store the result in @_has_next ivar
    def load
      if loaded? || limit_value.nil?
        super
      else
        set_limit_value limit_value + 1
        super
        set_limit_value limit_value - 1

        if @records.any?
          @records = @records.dup if (frozen = @records.frozen?)
          @_has_next = !!@records.delete_at(limit_value)
          @records.freeze if frozen
        end

        self
      end
    end

    # The page wouldn't be the last page if there's "limit + 1" record
    def last_page?
      !out_of_range? && !@_has_next
    end

    # Empty relation needs no pagination
    def out_of_range?
      load unless loaded?
      @records.empty?
    end

    # Force to raise an exception if #total_count is called explicitly.
    def total_count
      raise "This scope is marked as a non-count paginable scope and can't be used in combination " \
            "with `#paginate' or `#page_entries_info'. Use #link_to_next_page or #link_to_previous_page instead."
    end
  end
end

module Kaminari
  module CursorPaginatable
    # Overwrite AR::Relation#load to filter relative to cursor, reversing queried sort order is retrieving records
    # before the cursor. Loads an extra record to peek ahead and performs an additional query to peek behind one record,
    # using this information to set @_has_prev and @_has_next ivars
    def load peek: false
      if loaded? || limit_value.nil? || peek
        super()
      else
        # Normalize order to strings formatted as '(table.)?<column_name> (asc|desc)'
        order_strings = order_values
                          .map { |o| o.is_a?(Arel::Nodes::Ascending) ? "#{o.expr.relation.name}.#{o.expr.name} asc" : o }
                          .map { |o| o.is_a?(Arel::Nodes::Descending) ? "#{o.expr.relation.name}.#{o.expr.name} desc" : o }
                          .map { |o| o.split(',') }.flatten
                          .map { |o| o.downcase.strip }
                          .map { |o| o.end_with?('asc', 'desc') ? o : o + ' asc' }
        order_columns = order_strings.map(&:split).map(&:first).map{|o| o.split('.').last}
        order_dirs = order_strings.map(&:split).map(&:second)

        # Assert that ActiveRecord order columns come directly from model. (ordering by association columns
        # not supported).
        raise "Cursor pagination does not support ordering by associated columns" if order_values.map{|o| o.is_a?(Arel::Nodes::Ordering) ? o.expr.relation.name : nil}.compact.any?{|relation| relation != table_name}

        if !@_cursor
          condition = nil
          values = []
          has_peekback_record = false
        else
          # Assert that ActiveRecord order is in agreement with cursor
          column_disagreement = @_cursor.columns.pluck(:name).zip(order_columns).any? {|a, b| a != b }
          raise if column_disagreement

          # Generate condition to query `after`
          preceding_columns_per_column = @_cursor.columns.each_index.map{ |i| @_cursor.columns[0, i]}
          condition = @_cursor.columns.zip(preceding_columns_per_column, order_dirs)
                        .map { |column, preceding_columns, dir|
                          [preceding_columns.pluck(:name).map {|c| "#{c} = ?"} + [{'asc' => "#{column.name} > ?", 'desc' => "#{column.name} < ?"}.fetch(dir)]]
                            .join(' and ')
                        }
                        .map {|c| '(' + c + ')'}
                        .join(' or ')
          values = @_cursor.columns.zip(preceding_columns_per_column)
                     .map { |column, preceding_columns| preceding_columns.pluck(:value).append(column.value) }
                     .flatten

          # Reverse inequality signs if querying `before`
          reverse_inequalities = Proc.new { |condition| condition.gsub(/[<>]/, {'<' => '>', '>' => '<'})}
          condition = reverse_inequalities[condition] if @_querying_before_cursor

          # Peek back to detect any result in opposite direction
          peekback_condition = "(#{reverse_inequalities[condition]}) or (#{(@_cursor.columns.map {|c| c.name + ' = ? '}).join(' and ')})"
          peekback_values = values + @_cursor.columns.pluck(:value)
          peekback_relation = where(peekback_condition, *peekback_values).limit(1)
          order_strings.each { |o| peekback_relation.reorder!(o.gsub(/asc|desc/, {'asc' => 'desc', 'desc' => 'asc'})) }
          order_strings.each { |o| peekback_relation.reorder!(o.gsub(/asc|desc/, {'asc' => 'desc', 'desc' => 'asc'})) } if @_querying_before_cursor
          has_peekback_record = peekback_relation.load(peek: true).records.any?
        end

        # Apply condition
        where!(condition, *values) if condition

        # Reverse sort order if querying `before`
        order_strings.each { |o| reorder!(o.gsub(/asc|desc/, {'asc' => 'desc', 'desc' => 'asc'})) } if @_querying_before_cursor

        set_limit_value limit_value + 1
        super()
        set_limit_value limit_value - 1

        if @records.any?
          # Use extra and peekback to determine whether has next/prev page.
          # Re-reverse sort order if querying `before`.
          @records = @records.dup if (frozen = @records.frozen?)
          has_extra_record = !!@records.delete_at(limit_value)
          @records = @records.reverse if @_querying_before_cursor
          @_has_next = @_querying_before_cursor ? has_peekback_record : has_extra_record
          @_has_prev = @_querying_before_cursor ? has_extra_record : has_peekback_record
          @records.freeze if frozen

          # Generate start/end cursors for further paging
          start_cursor_values = order_columns.map { |c| @records.first.send(c) }
          end_cursor_values = order_columns.map { |c| @records.last.send(c) }
          @_page_start_cursor = Base64.encode64({'columns': order_columns.zip(order_dirs, start_cursor_values) .map { |name, dir, value| { 'name': name, 'dir': dir, 'value': value }} }.to_json)
          @_page_end_cursor = Base64.encode64({'columns': order_columns.zip(order_dirs, end_cursor_values) .map { |name, dir, value| { 'name': name, 'dir': dir, 'value': value }} }.to_json)
        end

        self
      end
    end
  end
end
