# frozen_string_literal: true

module Kaminari
  module CursorPageScopeMethods
    # Specify the <tt>per_page</tt> value for the preceding <tt>page</tt> scope
    #   Model.before(3).cursor_limit(10)
    #   Model.after(3).cursor_limit(10)
    def cursor_limit(num, cursor_max_limit=nil)
      cursor_max_limit ||= ( (defined?(@_cursor_max_limit) && @_cursor_max_limit) || self.cursor_max_limit)
      @_cursor_limit = (num || default_cursor_limit).to_i
      if (n = num.to_i) < 0 || !(/^\d/ =~ num.to_s)
        self
      elsif n.zero?
        limit(n)
      elsif cursor_max_limit && (cursor_max_limit < n)
        limit(cursor_max_limit)
      else
        limit(n)
      end
    end

  end
end
