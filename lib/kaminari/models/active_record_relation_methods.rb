module Kaminari
  module ActiveRecordRelationMethods
    def entry_name
      # If the model has a translated name, #human will use that. We pass
      # a manually pluralized default by using #element, which returns a
      # downcased and demodulized version of the class name, so
      # eg. User::Address becomes 'address'.
      # This keeps the functionality backwards compatible with older versions
      # of Kaminari.

      default = model_name.element
      default = ActiveSupport::Inflector.pluralize(default) if total_count != 1

      model_name.human(count: total_count, default: default)
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

        # .group returns an OrderedHash that responds to #count
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
