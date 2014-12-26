module Kaminari
  module PageScopeMethods
    # Specify the <tt>per_page</tt> value for the preceding <tt>page</tt> scope
    #   Model.page(3).per(10)
    def per(num)
      return self if (n = num.to_i) < 0 || !(/^\d/ =~ num.to_s)

      n = [num, max_per_page].compact.min
      limit(n).offset(offset_value / limit_value * n)
    end

    def padding(num)
      @_padding = num
      offset(offset_value + num.to_i)
    end

    def count_without_padding
      [ total_count - (@_padding || 0), 0 ].max
    end

    def offset_without_padding
      [ offset_value - (@_padding || 0), 0 ].max
    end

    # Total number of pages
    def total_pages
      [ (count_without_padding.to_f / limit_value).ceil, max_pages ].compact.min

    rescue FloatDomainError => e
      raise ZeroPerPageOperation, "The number of total pages was incalculable. Perhaps you called .per(0)?"
    end

    #FIXME for compatibility. remove num_pages at some time in the future
    alias num_pages total_pages

    # Current page number
    def current_page
      (offset_without_padding / limit_value) + 1

    rescue ZeroDivisionError => e
      raise ZeroPerPageOperation, "Current page was incalculable. Perhaps you called .per(0)?"
    end

    # Next page number in the collection
    def next_page
      current_page + 1 unless last_page? || out_of_range?
    end

    # Previous page number in the collection
    def prev_page
      current_page - 1 unless first_page? || out_of_range?
    end

    # First page of the collection?
    def first_page?
      current_page == 1
    end

    # Last page of the collection?
    def last_page?
      current_page == total_pages
    end

    # Out of range of the collection?
    def out_of_range?
      current_page > total_pages
    end
  end
end
