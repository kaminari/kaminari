# frozen_string_literal: true

require 'kaminari/activerecord/active_record_relation_methods'

module Kaminari
  module ActiveRecordModelExtension
    extend ActiveSupport::Concern

    included do
      include Kaminari::ConfigurationMethods

      # Fetch the values at the specified page number
      #   Model.page(5)
      eval <<-RUBY, nil, __FILE__, __LINE__ + 1
        def self.#{Kaminari.config.page_method_name}(num = nil)
          per_page = max_per_page && (default_per_page > max_per_page) ? max_per_page : default_per_page
          limit(per_page).offset(per_page * ((num = num.to_i - 1) < 0 ? 0 : num)).extending do
            include Kaminari::ActiveRecordRelationMethods
            include Kaminari::PageScopeMethods
          end
        end
      RUBY

      # Fetch the values after cursor
      #   Model.page_after(cursor: cursor)
      eval <<-RUBY, nil, __FILE__, __LINE__ + 1
        def self.#{Kaminari.config.page_after_method_name}(cursor = nil)
          self.#{Kaminari.config.page_by_cursor_method_name}(after: cursor)
        end
      RUBY

      # Fetch the values before cursor
      #   Model.page_before(cursor: cursor)
      eval <<-RUBY, nil, __FILE__, __LINE__ + 1
        def self.#{Kaminari.config.page_before_method_name}(cursor = nil)
          self.#{Kaminari.config.page_by_cursor_method_name}(before: cursor)
        end
      RUBY

      # Fetch the values after or before cursor
      # If both after and before are provided, use before.
      #   Model.page_by_cursor(after: cursor)
      eval <<-RUBY, nil, __FILE__, __LINE__ + 1
        def self.#{Kaminari.config.page_by_cursor_method_name}(after: nil, before: nil)
          per_page = max_per_page && (default_per_page > max_per_page) ? max_per_page : default_per_page

          # Decode cursor for `before` or `after` query
          after_h = JSON.parse(Base64.decode64(after)) if after
          before_h = JSON.parse(Base64.decode64(before)) if before
          cursor_h = before_h || after_h
          cursor = cursor_h ? JSON.parse({columns: cursor_h.each_pair.map{|name,value|{name: name.to_s, value: value&.to_s}}}.to_json, object_class:OpenStruct) : nil
          querying_before_cursor = before.present?

          if cursor
            # Validate cursor columns against model
            cursor_columns = cursor.columns.map { |c| c.name }
            model_columns = columns.map { |c| c.name }
            raise 'Cursor has columns that are not on model.' if (cursor_columns - model_columns).any?
          end
          
          relation = limit(per_page).extending do
            include Kaminari::ActiveRecordRelationMethods
            include Kaminari::CursorPageScopeMethods
            include Kaminari::CursorPaginatable
          end
          relation.instance_variable_set('@_cursor', cursor)
          relation.instance_variable_set('@_querying_before_cursor', querying_before_cursor)

          # Assert that ActiveRecord order columns come directly from model. (ordering by association columns not supported)
          raise "Cursor pagination does not support ordering by associated columns" if relation.ordered_by_unsupported_columns

          # Ensure that primary key is part of ordering
          relation = relation.order(primary_key + ' asc') unless relation.normalized_order_info[:columns].include? primary_key

          order_columns = relation.normalized_order_info[:columns]

          if !cursor
            condition = nil
            values = []
            peekback_relation = nil
          else
            # Coerce cursor column order into agreement with ActiveRecord order
            cursor.columns.filter! { |c| order_columns.include? c.name }
            cursor.columns.sort_by! { |c| order_columns.index(c.name) }

            # Generate condition to query `after`
            after_condition, after_values = relation.build_cursor_condition(:after)
            before_condition, before_values = relation.build_cursor_condition(:before)

            # Reverse inequality signs if querying `before`
            condition = querying_before_cursor ? before_condition : after_condition
            values = querying_before_cursor ? before_values : after_values

            # Peek back to detect any result in opposite direction
            peekback_condition = (querying_before_cursor ? after_condition : before_condition) + ' or (' + (cursor.columns.map {|c| c.value.nil? ? (c.name + ' is null ') : (c.name + ' = ? ')}).join(' and ') + ')'
            peekback_values = (querying_before_cursor ? after_values : before_values) + cursor.columns.map{|c| c.value}.compact
            peekback_relation = relation.where(peekback_condition, *peekback_values).limit(1)
            peekback_relation.reverse_order!
          end

          relation = relation.where(condition, *values) if condition
          relation = relation.reverse_order if querying_before_cursor

          relation.instance_variable_set('@_peekback_relation', peekback_relation)
          relation.instance_variable_set('@_order_columns', order_columns)

          relation
        end
      RUBY
    end
  end
end
