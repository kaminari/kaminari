# frozen_string_literal: true

module Kaminari
  module CursorPageScopeMethods
    # Specify the <tt>per_page</tt> value for the preceding <tt>page</tt> scope
    #   Model.page(3).per(10)
    def per(num, max_per_page: nil)
      max_per_page ||= ((defined?(@_max_per_page) && @_max_per_page) || self.max_per_page)
      @_per = (num || default_per_page).to_i
      if (n = num.to_i) < 0 || !(/^\d/ =~ num.to_s)
        self
      elsif n.zero?
        limit(n)
      elsif max_per_page && (max_per_page < n)
        limit(max_per_page)
      else
        limit(n)
      end
    end

    def max_paginates_per(new_max_per_page)
      @_max_per_page = new_max_per_page

      per (defined?(@_per) && @_per) || default_per_page, max_per_page: new_max_per_page
    end

    # Intentionally undefined
    #def padding(num)
    #end

    # Total number of pages
    def total_pages
      count_without_padding = total_count
      count_without_padding -= @_padding if defined?(@_padding) && @_padding
      count_without_padding = 0 if count_without_padding < 0

      total_pages_count = (count_without_padding.to_f / limit_value).ceil
      max_pages && (max_pages < total_pages_count) ? max_pages : total_pages_count
    rescue FloatDomainError
      raise ZeroPerPageOperation, "The number of total pages was incalculable. Perhaps you called .per(0)?"
    end

    # Intentionally undefined
    #def current_page
    #end

    def page_start_cursor
      @_page_start_cursor
    end

    def page_end_cursor
      @_page_end_cursor
    end

    # Intentionally undefined
    #def next_page
    #end

    # Intentionally undefined
    #def prev_page
    #end

    # Intentionally undefined
    #def first_page?
    #end

    # The page wouldn't be the last page if there's "limit + 1" record
    def first_page?
      !out_of_range? && !@_has_prev
    end

    def last_page?
      !out_of_range? && !@_has_next
    end

    # Empty relation needs no pagination
    def out_of_range?
      load unless loaded?
      @records.empty?
    end
  end
end
