module Kaminari
  module MongoidCriteriaMethods
    def limit_value #:nodoc:
      options[:limit]
    end

    def offset_value #:nodoc:
      options[:skip]
    end

    def total_count #:nodoc:
      @total_count ||=
        if embedded?
          unpage.count
        else
          counter_result = count
          if options[:max_scan] and options[:max_scan] < counter_result
            options[:max_scan]
          else
            counter_result
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
