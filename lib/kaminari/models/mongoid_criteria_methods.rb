module Kaminari
  module MongoidCriteriaMethods
    extend ActiveSupport::Concern
    module InstanceMethods
      def limit_value #:nodoc:
        options[:limit]
      end

      def offset_value #:nodoc:
        options[:skip]
      end

      def total_count #:nodoc:
        count
      end
    end
  end
end
