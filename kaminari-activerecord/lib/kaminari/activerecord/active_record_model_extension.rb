# frozen_string_literal: true

require 'kaminari/activerecord/active_record_relation_methods'

module Kaminari
  # Extends the Relation returned by Model.page.
  # Passing this module to `extending` rather than a block saves defining a new Module on each call.
  module ActiveRecordPageScope
    include Kaminari::ActiveRecordRelationMethods
    include Kaminari::PageScopeMethods
  end

  module ActiveRecordModelExtension
    extend ActiveSupport::Concern

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
          # spawn only once rather than calling limit, offset, and extending, each of which copies the Relation
          all.spawn.limit!(per_page).offset!(per_page * ((num = num.to_i - 1) < 0 ? 0 : num)).extending!(Kaminari::ActiveRecordPageScope)
        end
      RUBY
    end
  end
end
