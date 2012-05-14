module Kaminari
  module MongoidCriteriaMethods
    def limit_value #:nodoc:
      options[:limit]
    end

    def offset_value #:nodoc:
      options[:skip]
    end

    def total_count #:nodoc:
      embedded? ? unpage.count : count
    end

    def current_page_count #:nodoc:
      # TODO: this needs a better fix, count comes from Mongoid::Context::Mongo or Enumerable which have different signatures
      begin
        count(true)
      rescue ArgumentError
        count
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
