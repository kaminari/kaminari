# frozen_string_literal: true
require 'kaminari/activerecord/active_record_relation_methods'

module Kaminari
  class CollectionNotOrderedError < RuntimeError; end

  module ActiveRecordModelExtension
    extend ActiveSupport::Concern

    included do
      include Kaminari::ConfigurationMethods

      # Fetch the values at the specified page number
      #   Model.page(5)
      eval <<-RUBY, nil, __FILE__, __LINE__ + 1
        def self.#{Kaminari.config.page_method_name}(num = nil)
          per_page = max_per_page && (default_per_page > max_per_page) ? max_per_page : default_per_page

          if Kaminari.config.mandatory_ordering && all.values.fetch(:order, []).none?
            raise Kaminari::CollectionNotOrderedError
          end

          limit(per_page).offset(per_page * ((num = num.to_i - 1) < 0 ? 0 : num)).extending do
            include Kaminari::ActiveRecordRelationMethods
            include Kaminari::PageScopeMethods
          end
        end
      RUBY
    end
  end
end
