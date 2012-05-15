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
      if Mongoid::VERSION =~ /^3/
        current_page_count_mongoid3
      else
        current_page_count_mongoid2
      end
    end

    private
    def unpage
      clone.tap do |crit|
        crit.options.delete :limit
        crit.options.delete :skip
      end
    end

    def current_page_count_mongoid2
      # TODO: this needs a better fix, count comes from Mongoid::Context::Mongo or Enumerable which have different signatures
      begin
        count(true)
      rescue ArgumentError
        count
      end
    end

    def current_page_count_mongoid3
      if embedded?
        count
      else
        # can't use count if PR https://github.com/mongoid/moped/pull/7 not merge
        context.entries.size
      end
    end
  end
end
