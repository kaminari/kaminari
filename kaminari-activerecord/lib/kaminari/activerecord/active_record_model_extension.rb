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

      # cursor paginate with before
      #   Model.before(5)
      eval <<-RUBY, nil, __FILE__, __LINE__ + 1
        def self.#{Kaminari.config.before_method_name}(position)
          @_cursor_paginate_direction = 'before'
          cursor_limit = cursor_max_limit && (default_cursor_limit > cursor_max_limit) ? cursor_max_limit : default_cursor_limit
          limit(cursor_limit).where(arel_table[primary_key].lt(position)).reorder(primary_key => :desc).extending do
            def cursor_paginate_direction
              'before'
            end

            include Kaminari::ActiveRecordRelationMethods
            include Kaminari::CursorPageScopeMethods
          end
        end
      RUBY

      # cursor paginate with after
      #   Model.after(5)
      eval <<-RUBY, nil, __FILE__, __LINE__ + 1
        def self.#{Kaminari.config.after_method_name}(position)
          @_cursor_paginate_direction = 'after'
          cursor_limit = cursor_max_limit && (default_cursor_limit > cursor_max_limit) ? cursor_max_limit : default_cursor_limit
          limit(cursor_limit).where(arel_table[primary_key].gt(position)).reorder(primary_key => :asc).extending do

            def cursor_paginate_direction
              'after'
            end

            include Kaminari::ActiveRecordRelationMethods
            include Kaminari::CursorPageScopeMethods
          end
        end
      RUBY


    end
  end
end
