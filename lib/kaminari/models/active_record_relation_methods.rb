module Kaminari
  module ActiveRecordRelationMethods
    extend ActiveSupport::Concern
    module InstanceMethods
      def total_count #:nodoc:
        @_c ||= except(:offset, :limit).count
        # .group returns an OrderdHash that responds to #count
        @_result ||= @_c.respond_to?(:count) ? @_c.count : @_c
      end
    end
  end
end
