module Kaminari
  module ActiveRecordRelationMethods
    extend ActiveSupport::Concern
    module InstanceMethods
      def total_count #:nodoc:
        except(:offset, :limit).count
      end
    end
  end
end
