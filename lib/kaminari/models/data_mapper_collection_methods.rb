module Kaminari
  module DataMapperCollectionMethods
    def entry_name
      model.model_name.human.downcase
    end

    def limit_value #:nodoc:
      query.options[:limit] || 0
    end

    def offset_value #:nodoc:
      query.options[:offset] || 0
    end

    def total_count #:nodoc:
      model.count(query.options.except(:limit, :offset, :order))
    end
  end
end
