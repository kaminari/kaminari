module Kaminari
  module PluckyCriteriaMethods
    def limit_value #:nodoc:
      options[:limit]
    end

    def offset_value #:nodoc:
      options[:skip]
    end

    def total_count #:nodoc:
      count
    end

    def current_page_count #:nodoc:
      # TODO: this needs a better fix, ie. pass skip_and_limit = true
      # into http://api.mongodb.org/ruby/1.2.0/Mongo/Cursor.html#count-instance_method
      to_a.count
    end
  end
end
