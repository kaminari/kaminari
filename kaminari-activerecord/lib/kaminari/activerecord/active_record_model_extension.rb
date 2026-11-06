# frozen_string_literal: true

require 'kaminari/activerecord/active_record_relation_methods'

module Kaminari
  # Extends the Relation returned by Model.page.
  # Passing this module to `extending` rather than a block saves defining a new Module on each call.
  module ActiveRecordPageScope
    include Kaminari::PageScopeMethods
    # included after PageScopeMethods so that it can override PageScopeMethods#limit_and_offset
    include Kaminari::ActiveRecordRelationMethods
  end

  module ActiveRecordModelExtension
    extend ActiveSupport::Concern

    MAX_OFFSET = (2**63) - 1

    included do
      include Kaminari::ConfigurationMethods

      def self.paginated?
        false
      end

      # Fetch the values at the specified page number
      #   Model.page(5)
      eval <<-RUBY, nil, __FILE__, __LINE__ + 1
        def self.#{Kaminari.config.page_method_name}(num = nil)
          num = num.respond_to?(:to_i) ? num.to_i : 1
          per_page = max_per_page && (default_per_page > max_per_page) ? max_per_page : default_per_page
          offset = per_page * ((num = num.to_i - 1) < 0 ? 0 : num)
          # Spawn once on the common path; an overflowing offset represents an empty page.
          relation = all.spawn.limit!(per_page)
          relation = relation.none if offset > Kaminari::ActiveRecordModelExtension::MAX_OFFSET
          relation.offset!(offset > Kaminari::ActiveRecordModelExtension::MAX_OFFSET ? 0 : offset).extending!(Kaminari::ActiveRecordPageScope)
        end
      RUBY
    end
  end
end
