module Kaminari
  module MongoidCriteriaMethods
    extend ActiveSupport::Concern
    module InstanceMethods
      def limit_value
        options[:limit]
      end
      def offset_value
        options[:skip]
      end
      def pagination_count
        count
      end
    end
  end
end
