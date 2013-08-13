module Kaminari
  module PageScopeMethods
    # Specify the <tt>per_page</tt> value for the preceding <tt>page</tt> scope
    #   Model.page(3).per(10)
    def per(num)
      if (n = num.to_i) <= 0
        self
      elsif max_per_page && max_per_page < n
        limit(max_per_page).offset(offset_value / limit_value * max_per_page)
      else
        limit(n).offset(offset_value / limit_value * n)
      end
    end

    def padding(num)
      @_padding = num
      offset(offset_value + num.to_i)
    end

    # Total number of pages
    def total_pages
      if infinite_pages?
        :infinite
      else
        count_without_padding = total_count
        count_without_padding -= @_padding if defined?(@_padding) && @_padding
        count_without_padding = 0 if count_without_padding < 0

        total_pages_count = (count_without_padding.to_f / limit_value).ceil
        if max_pages.present? && max_pages < total_pages_count
          max_pages
        else
          total_pages_count
        end
      end
    end
    #FIXME for compatibility. remove num_pages at some time in the future
    alias num_pages total_pages

    # Current page number
    def current_page
      offset_without_padding = offset_value
      offset_without_padding -= @_padding if defined?(@_padding) && @_padding
      offset_without_padding = 0 if offset_without_padding < 0

      (offset_without_padding / limit_value) + 1
    end

    # Next page number in the collection
    def next_page
      current_page + 1 unless last_page?
    end

    # Previous page number in the collection
    def prev_page
      current_page - 1 unless first_page?
    end

    # First page of the collection?
    def first_page?
      current_page == 1
    end

    # Last page of the collection?
    def last_page?
      total_pages == :infinite ? false : current_page >= total_pages
    end

    # Out of range of the collection?
    def out_of_range?
      total_pages == :infinite ? false : current_page > total_pages
    end
  end
end
