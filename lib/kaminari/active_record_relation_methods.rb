module Kaminari
  module ActiveRecordRelationMethods
    extend ActiveSupport::Concern
    module InstanceMethods
      def pagination_count
        except(:offset, :limit).count
      end
    end
  end
end
