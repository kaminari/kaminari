module Kaminari
  module ActiveRecordRelationMethods
    extend ActiveSupport::Concern
    module InstanceMethods
      def total_count #:nodoc:
        c = except(:offset, :limit, :includes).count
        # .group returns an OrderdHash that responds to #count
        c.respond_to?(:count) ? c.count : c
      end
    end
  end
end
