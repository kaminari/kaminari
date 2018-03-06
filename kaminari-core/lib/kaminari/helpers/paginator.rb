# frozen_string_literal: true
require 'active_support/inflector'
require 'kaminari/helpers/tags'

module Kaminari
  module Helpers
    # The main container tag
    class Paginator
      def initialize(router: , window: nil, outer_window: Kaminari.config.outer_window, left: Kaminari.config.left, right: Kaminari.config.right, inner_window: Kaminari.config.window, **options) #:nodoc:
        @window_options = {window: window || inner_window, left: left.zero? ? outer_window : left, right: right.zero? ? outer_window : right}

        @router, @options, @theme, @views_prefix, @last = router, options, options[:theme], options[:views_prefix], nil
        @window_options.merge! @options
        @window_options[:current_page] = @options[:current_page]
      end

      def page_url_for(page_tag)
        @router.page_url_for(page_tag.page)
      end

      def to_partial_path
        [ @views_prefix, "kaminari", @theme, self.class.name.demodulize.underscore ].compact.join("/")
      end

      # enumerate each page providing PageProxy object as the block parameter
      # Because of performance reason, this doesn't actually enumerate all pages but pages that are seemingly relevant to the paginator.
      # "Relevant" pages are:
      # * pages inside the left outer window plus one for showing the gap tag
      # * pages inside the inner window plus one on the left plus one on the right for showing the gap tags
      # * pages inside the right outer window plus one for showing the gap tag
      def each_relevant_page
        return to_enum(:each_relevant_page) unless block_given?

        current_page, total_pages =  @options[:current_page], @options[:total_pages]

        [
          FirstPage.new(page: 1,               current: current_page, theme: @theme, views_prefix: @views_prefix),
          PrevPage.new(page: current_page - 1, current: current_page, theme: @theme, views_prefix: @views_prefix),
          relevant_pages.map { |page| Page.new(page: page, current: current_page, theme: @theme, views_prefix: @views_prefix) },
          NextPage.new(page: current_page + 1, current: current_page, theme: @theme, views_prefix: @views_prefix),
          LastPage.new(page: total_pages,      current: current_page, theme: @theme, views_prefix: @views_prefix),
        ].flatten.each {|page| yield page }
      end
      alias each_page each_relevant_page

      def relevant_pages(options = @window_options)
        left_window_plus_one = [*1..options[:left] + 1]
        right_window_plus_one = [*options[:total_pages] - options[:right]..options[:total_pages]]
        inside_window_plus_each_sides = [*options[:current_page] - options[:window] - 1..options[:current_page] + options[:window] + 1]

        (left_window_plus_one | inside_window_plus_each_sides | right_window_plus_one).sort.reject {|x| (x < 1) || (x > options[:total_pages])}
      end

      class Page
        attr_reader :page, :current, :rel

        def initialize(page: , current: false, theme: nil, views_prefix: nil)
          @page = page
          @current = current
          @theme = theme
          @views_prefix = views_prefix
        end

        def current?
          page == current
        end

        def current_page
          PageProxy.new(page, current_page: current)
        end

        def to_partial_path
          [ @views_prefix, "kaminari", @theme, self.class.name.demodulize.underscore ].compact.join("/")
        end

        def to_s
          page.to_s
        end
      end

      class FirstPage < Page; end
      class PrevPage < Page; end
      class NextPage < Page; end
      class LastPage < Page; end

      class PageProxy < SimpleDelegator
        attr_reader :current_page

        def initialize(page, current_page: )
          super(page.to_i)
          @current_page = current_page
        end

        def first?
          1 == current_page
        end

        def last?
          __getobj__ == current_page
        end
      end
    end
  end
end
