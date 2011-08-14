module Kaminari
  module DataMapperCollectionMethods
    extend ActiveSupport::Concern
    module InstanceMethods
      def limit_value #:nodoc:
        query.options[:limit] || 0
      end

      def offset_value #:nodoc:
        query.options[:offset] || 0
      end

      def total_count #:nodoc:
        return count if query.options.blank?
        opts = query.options.dup
        opts.delete(:limit)
        opts.delete(:offset)
        opts.delete(:order)
        model.all(opts).count
      end
    end
  end
end