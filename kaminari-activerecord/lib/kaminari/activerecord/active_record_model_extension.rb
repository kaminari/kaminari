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
          num = num.respond_to?(:to_i) ? num.to_i : 1
          per_page = max_per_page && (default_per_page > max_per_page) ? max_per_page : default_per_page
          scope = limit(per_page).offset(per_page * ((num = num.to_i - 1) < 0 ? 0 : num)).extending do
            include Kaminari::ActiveRecordRelationMethods
            include Kaminari::PageScopeMethods
          end
          # Using limit and offset is unreliable without ordering
          # Warn the developers using paginatin wihout the order clause
          if scope.order_values.empty?
            warn "WARNING: It seems you're using pagination without an ORDER BY clause."
            warn "This might result in unexpected or random records on paginated results."
          end
          scope
        end
      RUBY
    end
  end
end
