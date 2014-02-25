module Kaminari
  module PluckyCriteriaMethods
    include Kaminari::PageScopeMethods

    delegate :default_per_page, :max_per_page, :max_pages, to: :model

    def limit_value #:nodoc:
      options[:limit]
    end

    def offset_value #:nodoc:
      options[:skip]
    end

    def total_count #:nodoc:
      count
    end
  end
end
