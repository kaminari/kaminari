require File.join(File.dirname(__FILE__), 'tags')
require 'action_view/context'

module Kaminari
  module Helpers
    # The main container tag
    class Paginator < Tag
      # so that this instance can actually "render"
      include ::ActionView::Context

      def initialize(template, options) #:nodoc:
        @window_options = {}.tap do |h|
          h[:window] = options.delete(:window) || options.delete(:inner_window) || Kaminari.config.window
          outer_window = options.delete(:outer_window) || Kaminari.config.outer_window
          h[:left] = options.delete(:left) || Kaminari.config.left
          h[:left] = outer_window if h[:left] == 0
          h[:right] = options.delete(:right) || Kaminari.config.right
          h[:right] = outer_window if h[:right] == 0
        end
        @template, @options = template, options
        @theme = @options[:theme] ? "#{@options[:theme]}/" : ''
        @options[:current_page] = PageProxy.new @window_options.merge(@options), @options[:current_page], nil
        # initialize the output_buffer for Context
        @output_buffer = ActionView::OutputBuffer.new
      end

      # render given block as a view template
      def render(&block)
        instance_eval &block if @options[:num_pages] > 1
        @output_buffer
      end

      # enumerate each page providing PageProxy object as the block parameter
      def each_page
        return to_enum(:each_page) unless block_given?

        1.upto(@options[:num_pages]) do |i|
          yield PageProxy.new(@window_options.merge(@options), i, @last)
        end
      end

      def page_tag(page)
        @last = Page.new @template, @options.merge(:page => page)
      end

      %w[first_page prev_page next_page last_page gap].each do |tag|
        eval <<-DEF
          def #{tag}_tag
            @last = #{tag.classify}.new @template, @options
          end
        DEF
      end

      def to_s #:nodoc:
        subscriber = ActionView::LogSubscriber.log_subscribers.detect {|ls| ls.is_a? ActionView::LogSubscriber}
        return super @window_options.merge(@options).merge :paginator => self unless subscriber

        # dirty hack to suppress logging render_partial
        class << subscriber
          alias_method :render_partial_with_logging, :render_partial
          # do nothing
          def render_partial(event); end
        end

        ret = super @window_options.merge(@options).merge :paginator => self

        class << subscriber
          alias_method :render_partial, :render_partial_with_logging
          undef :render_partial_with_logging
        end
        ret
      end

      # Wraps a "page number" and provides some utility methods
      class PageProxy
        include Comparable

        def initialize(options, page, last) #:nodoc:
          @options, @page, @last = options, page, last
        end

        # the page number
        def number
          @page
        end

        # current page or not
        def current?
          @page == @options[:current_page]
        end

        # the first page or not
        def first?
          @page == 1
        end

        # the last page or not
        def last?
          @page == @options[:num_pages]
        end

        # the previous page or not
        def prev?
          @page == @options[:current_page] - 1
        end

        # the next page or not
        def next?
          @page == @options[:current_page] + 1
        end

        # within the left outer window or not
        def left_outer?
          @page <= @options[:left]
        end

        # within the right outer window or not
        def right_outer?
          @options[:num_pages] - @page < @options[:right]
        end

        # inside the inner window or not
        def inside_window?
          (@options[:current_page] - @page).abs <= @options[:window]
        end

        # The last rendered tag was "truncated" or not
        def was_truncated?
          @last.is_a? Gap
        end

        def to_i
          number
        end

        def to_s
          number.to_s
        end

        def +(other)
          to_i + other.to_i
        end

        def -(other)
          to_i - other.to_i
        end

        def <=>(other)
          to_i <=> other.to_i
        end
      end
    end
  end
end
