module Kaminari
  module DataMapperCollectionMethods
    def limit_value #:nodoc:
      query.options[:limit] || 0
    end

    def offset_value #:nodoc:
      query.options[:offset] || 0
    end

    def total_count #:nodoc:
      model.count(query.options.except(:limit, :offset, :order))
    end

    def current_page_count #:nodoc:
      count
    end

  end
end
