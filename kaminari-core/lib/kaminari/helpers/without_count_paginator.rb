# frozen_string_literal: true
require 'kaminari/helpers/paginator'

module Kaminari
  module Helpers
    class WithoutCountPaginator < Paginator
      private :relevant_pages

      def relevant_pages(options)
        super.select { |page| page <= options[:current_page].to_i }
      end
    end
  end
end
