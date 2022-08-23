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
          after_h = JSON.parse(Base64.decode64(after), object_class: OpenStruct) if after
          before_h = JSON.parse(Base64.decode64(before), object_class: OpenStruct) if before
          cursor = before_h || after_h
          querying_before_cursor = before.present?

          if cursor
            # Validate cursor columns against model
            cursor_columns = cursor.columns.map { |c| c.name }
            model_columns = columns.map { |c| c.name }
            raise 'Cursor has columns that are not on model.' if (cursor_columns - model_columns).any?

            # TODO Assert that cursor is unique, e.g. any column is unique or any subset of columns is unique.
          end
          
          limit(per_page).extending do
            include Kaminari::ActiveRecordRelationMethods
            include Kaminari::CursorPageScopeMethods
            include  Kaminari::CursorPaginatable
          end
          .tap do |relation|
            relation.instance_variable_set('@_cursor', cursor)
            relation.instance_variable_set('@_querying_before_cursor', querying_before_cursor)
          end
        end
      RUBY
    end
  end
end
