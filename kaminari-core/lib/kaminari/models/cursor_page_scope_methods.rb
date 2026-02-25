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

    # Intentionally undefined
    #def total_pages
    #end

    # Intentionally undefined
    #def current_page
    #end

    def start_cursor
      load unless loaded?
      Base64.strict_encode64(@_start_cursor.to_json)
    end

    def end_cursor
      load unless loaded?
      Base64.strict_encode64(@_end_cursor.to_json)
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
