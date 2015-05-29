module Kaminari
  module ActiveRecordRelationMethods
    def entry_name
      model_name.human.downcase
    end

    def reset #:nodoc:
      @total_count = nil
      super
    end

    # return the relation without any pagination
    #
    #
    # Example:
    #   user.books_authored.page(1).unpaged
    # => return user's all books without pagination
    #
    def unpaged
      _unpaged = except(:offset, :limit, :order)

      # Remove includes only if they are irrelevant
      _unpaged.except(:includes) unless references_eager_loaded_tables?

      _unpaged
    end

    def total_count(column_name = :all, options = {}) #:nodoc:
      # #count overrides the #select which could include generated columns referenced in #order, so skip #order here, where it's irrelevant to the result anyway
      @total_count ||= begin
        # Rails 4.1 removes the `options` argument from AR::Relation#count
        args = [column_name]
        args << options if ActiveRecord::VERSION::STRING < '4.1.0'

        # .group returns an OrderdHash that responds to #count
        c = unpaged.count(*args)
        if c.is_a?(Hash) || c.is_a?(ActiveSupport::OrderedHash)
          c.count
        else
          c.respond_to?(:count) ? c.count(*args) : c
        end
      end
    end
  end
end
