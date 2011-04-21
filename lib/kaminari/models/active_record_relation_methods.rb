module Kaminari
  module ActiveRecordRelationMethods
    extend ActiveSupport::Concern
    module InstanceMethods
      # a workaround for AR 3.0.x that returns 0 for #count when page > 1
      if Rails.version < '3.1'
        def count #:nodoc:
          limit_value == 0 ? 0 : length
        end
      end

      def total_count #:nodoc:
        # #count overrides the #select which could include generated columns referenced in #order, so skip #order here, where it's irrelevant to the result anyway
        c = except(:offset, :limit, :includes, :order).count
        # .group returns an OrderdHash that responds to #count
        c.respond_to?(:count) ? c.count : c
      end
    end
  end
end
