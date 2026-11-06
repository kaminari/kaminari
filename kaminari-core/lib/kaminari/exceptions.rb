# frozen_string_literal: true

module Kaminari
  class ZeroPerPageOperation < ZeroDivisionError; end

  # Raised when a page number cannot be used as a SQL OFFSET.
  # Page numbers above a signed 32-bit integer overflow common databases.
  class InvalidPage < ArgumentError
    MAX = 2_147_483_647
  end
end
