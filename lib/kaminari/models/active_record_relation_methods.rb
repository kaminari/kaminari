module Kaminari
  module ActiveRecordRelationMethods
    extend ActiveSupport::Concern
    module InstanceMethods
      if Rails.version < '3.1'
        def count #:nodoc:
          limit_value == 0 ? 0 : length
        end
      end

      def total_count #:nodoc:
        c = except(:offset, :limit, :order).count
        # .group returns an OrderdHash that responds to #count
        c.respond_to?(:count) ? c.count : c
      end
    end
  end
end
