module Kaminari
  module MongoidCriteriaMethods
    def initialize_copy(other) #:nodoc:
      @total_count = nil
      super
    end

    def entry_name
      model_name.human.downcase
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

      if @_max_num_pages.present? && @_max_num_pages < @total_count
        limit_value * @_max_num_pages
      else
        @total_count
      end
    end

    def empty_instance
      self.where(id: nil)
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
