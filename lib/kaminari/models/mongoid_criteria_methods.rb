require 'kaminari/models/entry_methods'

module Kaminari
  module MongoidCriteriaMethods
    include Kaminari::EntryMethods

    def initialize_copy(other) #:nodoc:
      @total_count = nil
      super
    end

    def limit_value #:nodoc:
      options[:limit]
    end

    def offset_value #:nodoc:
      options[:skip]
    end

    def total_count #:nodoc:
      @total_count ||= if embedded?
        unpage.size
      else
        if options[:max_scan] && options[:max_scan] < size
          options[:max_scan]
        else
          size
        end
      end
    end

    private
    def unpage
      clone.tap do |crit|
        crit.options.delete :limit
        crit.options.delete :skip
      end
    end
  end
end
