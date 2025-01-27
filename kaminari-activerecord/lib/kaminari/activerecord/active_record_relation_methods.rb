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
        return @total_count = offset_value + @records.length if @records.any? && (@records.length < limit_value)
      end

      # #count overrides the #select which could include generated columns referenced in #order, so skip #order here, where it's irrelevant to the result anyway
      c = except(:offset, :limit, :order)
      # Remove includes only if they are irrelevant
      c = c.except(:includes, :eager_load, :preload) unless references_eager_loaded_tables?

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
    using Kaminari::PaginatableWithoutCount::LimitValueSetter

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
    # Overwrite AR::Relation#load to filter relative to cursor and peek ahead/behind.
    def load peek: false
      if loaded? || limit_value.nil? || peek
        super()
      else
        has_peekback_record = @_peekback_relation ? @_peekback_relation.load(peek: true).records.any? : false

        set_limit_value limit_value + 1
        super()
        set_limit_value limit_value - 1

        if @records.any?
          # Use extra record and peekback record to determine whether has next/prev page.
          # Re-reverse sort order if querying `before`.
          @records = @records.dup if (frozen = @records.frozen?)
          has_extra_record = !!@records.delete_at(limit_value)
          @records = @records.reverse if @_querying_before_cursor
          @_has_next = @_querying_before_cursor ? has_peekback_record : has_extra_record
          @_has_prev = @_querying_before_cursor ? has_extra_record : has_peekback_record
          @records.freeze if frozen

          # Generate start/end cursors for further paging
          @_start_cursor = build_cursor_from_record @records.first
          @_start_cursor[Kaminari.config.page_direction_attr_name] = 'before'
          @_end_cursor = build_cursor_from_record @records.last
          @_end_cursor[Kaminari.config.page_direction_attr_name] = 'after'
        end

        self
      end
    end

    # Force to raise an exception if #total_count is called explicitly.
    def total_count
      raise "This scope is marked as a cursor paginable scope and can't be used in combination " \
            "with `#paginate' or `#page_entries_info'. Use #link_to_page_after or #link_to_page_before instead."
    end

    def build_cursor_from_record(record)
      cursor_values = @_order_columns.map { |c| record.read_attribute_before_type_cast(c) }

      # Serialize timestamps with nanoseconds.
      cursor_values = cursor_values.map do |value|
        if value.respond_to?(:xmlschema)
          value.xmlschema(9)  # nanoseconds
        else
          value
        end
      end

      Hash[@_order_columns.zip(cursor_values)]
    end

    def build_cursor_condition(search_direction)
      order_dirs = normalized_order_info[:dirs]
      explicit_null_position_per_column = normalized_order_info[:explicit_null_positions]
      asc_operator = {after: '>', before: '<'}.fetch(search_direction)
      desc_operator = {after: '<', before: '>'}.fetch(search_direction)
      preceding_columns_per_column = @_cursor.columns.each_index.map{|i| @_cursor.columns[0, i]}
      nulls_after_per_column = explicit_null_position_per_column.zip(order_dirs).map {|explicit_null_position, dir|
        case explicit_null_position
        when 'first'
          false
        when 'last'
          true
        else
          (dir == :asc and db_defaults_to_large_nulls) or (dir == :desc and !db_defaults_to_large_nulls)
        end
      }
      condition = @_cursor.columns.zip(preceding_columns_per_column, order_dirs, nulls_after_per_column)
                          .map { |column, preceding_columns, dir, nulls_after|
                          nulls_last = (nulls_after and search_direction == :after) || (!nulls_after and search_direction == :before)
                          if column.value.nil?
                            inequality = nulls_last ? nil : "#{column.full_name} is not null"
                          else
                            inequality = {asc: "#{column.full_name} #{asc_operator} ?", desc: "#{column.full_name} #{desc_operator} ?"}.fetch(dir)
                            inequality += " or #{column.full_name} is null" if nulls_last
                          end
                          inequality.nil? ? nil : (preceding_columns.map{|c| [c.full_name, c.value]} .map {|c, v| v.nil? ? "#{c} is null" : "#{c} = ?" } + ['(' + inequality + ')']).join(' and ')
                        }
                        .compact
                        .map {|c| '(' + c + ')'}
                        .join(' or ')
      values = @_cursor.columns.zip(preceding_columns_per_column, nulls_after_per_column)
                       .map { |column, preceding_columns, nulls_after|
                         nulls_last = (nulls_after and search_direction == :after) || (!nulls_after and search_direction == :before)
                         (column.value.nil? and nulls_last) ? nil : (preceding_columns.map{|c| c.value} + [column.value])
                       }
                       .flatten
                       .compact
      return condition, values
    end

    def normalized_order_info
      # Normalize order to strings formatted as '(table.)?<column_name> (asc|desc)( nulls (first|last))?'
      order_strings = order_values
        .map { |o| o.is_a?(Arel::Nodes::Ordering) ? o.to_sql : o }
        .map { |o| o.split(',') }.flatten
        .map { |o| o.downcase.strip }
        .map { |o| o.gsub(/(?<!")"(([^"]|"")+)"(?!")/, '\1') }
        .map { |o| o.match(/\s+(asc|desc)(\s+nulls\s+(first|last))?/) ? o : o.sub(/(\s+nulls\s+(first|last))?$/, ' asc\0') }
      return {
        columns: order_strings.map(&:split).map(&:first).map{|o| split_and_unquote_identifiers(o).last},
        dirs: order_strings.map{|o| o.match(/\s+(asc|desc)(\s+nulls\s+(first|last))?/)}.map{|o| o[1].to_sym},
        explicit_null_positions: order_strings.map{|o| o.match(/\s+(asc|desc)(\s+nulls\s+(first|last))?/)}.map{|o| o[3]}
      }
    end

    def split_and_unquote_identifiers fully_qualified_identifier

      # Split identifiers that may be quoted or unquoted
      grave_quoted_identifier = '(?=`(?:[^`]|`{2})*`)'
      double_quoted_identifier = '(?="(?:[^"]|"{2})*")'
      non_quoted_identifier_terminated_by_dot = '(?=(?:[^"`]+\.))'
      non_quoted_identifier_terminated_by_end = '(?=(?:[^"`]+$))'

      adapter_type = connection.adapter_name.downcase.to_sym
      identifiers = [non_quoted_identifier_terminated_by_dot, non_quoted_identifier_terminated_by_end]
      identifiers += [grave_quoted_identifier] if [:mysql, :mysql2, :sqlite].include? adapter_type
      identifiers += [double_quoted_identifier] if [:postgresql, :sqlite].include? adapter_type

      quoted_identifiers = fully_qualified_identifier.split(/\.(?:#{identifiers.join('|')})/)

      # Unquote identifiers
      unquoted_identifiers = (
        quoted_identifiers
          .map{|s| s[ /`(([^`]|`{2})*)`/, 1] || s}  # Unquote grave quoted identifiers
          .map{|s| s[/"(([^"]|"{2})*)"/, 1] || s}  # Unquote double quoted identifiers
      )
      return unquoted_identifiers

    end

    def ordered_by_unsupported_columns
      order_values.map{|o| (o.is_a?(Arel::Nodes::Ascending) or o.is_a?(Arel::Nodes::Descending)) ? o.expr.relation.name : nil}.compact.any?{|relation| relation != table_name}
    end

    def db_defaults_to_large_nulls
      case adapter_type = connection.adapter_name.downcase.to_sym
      when :mysql, :mysql2
        false
      when :sqlite
        false
      when :postgresql
        true
      else
        raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
      end
    end
  end
end
