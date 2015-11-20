module Kaminari
  module ActiveRecordRelationMethods
    def entry_name( options = {} )
      count = options.fetch(:count, 1) # back compatibility where default was singular humanized model name
      downcase = options.fetch(:downcase, true) # back compatibility where default was to downcase entry_name
      entry_name = model_name.human(count: count)
      downcase ? entry_name.downcase : entry_name
     end

    def reset #:nodoc:
      @total_count = nil
      super
    end

    def total_count(column_name = :all, options = {}) #:nodoc:
      # #count overrides the #select which could include generated columns referenced in #order, so skip #order here, where it's irrelevant to the result anyway
      @total_count ||= begin
        c = except(:offset, :limit, :order)

        # Remove includes only if they are irrelevant
        c = c.except(:includes) unless references_eager_loaded_tables?

        # Rails 4.1 removes the `options` argument from AR::Relation#count
        args = [column_name]
        args << options if ActiveRecord::VERSION::STRING < '4.1.0'

        # .group returns an OrderdHash that responds to #count
        c = c.count(*args)
        if c.is_a?(Hash) || c.is_a?(ActiveSupport::OrderedHash)
          c.count
        else
          c.respond_to?(:count) ? c.count(*args) : c
        end
      end
    end
  end
end
