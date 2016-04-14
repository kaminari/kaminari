require 'active_support/inflector'
require 'action_view'
require 'action_view/log_subscriber'
require 'action_view/context'
require 'kaminari/helpers/tags'

module Kaminari
  module Helpers
    # The main container tag
    class Paginator < Tag
      # so that this instance can actually "render"
      include ::ActionView::Context

      def initialize(template, options) #:nodoc:
        ActiveSupport::Deprecation.warn 'num_pages is deprecated and will be removed in Kaminari 1.0. Please use total_pages instead.' if options.has_key? :num_pages
        options[:num_pages] ||= options[:total_pages]

        @window_options = {}.tap do |h|
          h[:window] = options.delete(:window) || options.delete(:inner_window) || Kaminari.config.window
          outer_window = options.delete(:outer_window) || Kaminari.config.outer_window
          h[:left] = options.delete(:left) || Kaminari.config.left
          h[:left] = outer_window if h[:left] == 0
          h[:right] = options.delete(:right) || Kaminari.config.right
          h[:right] = outer_window if h[:right] == 0
        end
        @template, @options = template, options
        @theme = @options[:theme]
        @views_prefix = @options[:views_prefix]
        @window_options.merge! @options
        @window_options[:current_page] = @options[:current_page] = PageProxy.new(@window_options, @options[:current_page], nil)

        @last = nil
        # initialize the output_buffer for Context
        @output_buffer = ActionView::OutputBuffer.new
      end

      # render given block as a view template
      def render(&block)
        instance_eval(&block) if @options[:total_pages] > 1
        @output_buffer
      end

      # enumerate each page providing PageProxy object as the block parameter
      # Because of performance reason, this doesn't actually enumerate all pages but pages that are seemingly relevant to the paginator.
      # "Relevant" pages are:
      # * pages inside the left outer window plus one for showing the gap tag
      # * pages inside the inner window plus one on the left plus one on the right for showing the gap tags
      # * pages inside the right outer window plus one for showing the gap tag
      def each_relevant_page
        return to_enum(:each_relevant_page) unless block_given?

        relevant_pages(@window_options).each do |page|
          yield PageProxy.new(@window_options, page, @last)
        end
      end
      alias each_page each_relevant_page

      def relevant_pages(options)
        left_window_plus_one = 1.upto(options[:left] + 1).to_a
        right_window_plus_one = (options[:total_pages] - options[:right]).upto(options[:total_pages]).to_a
        inside_window_plus_each_sides = (options[:current_page] - options[:window] - 1).upto(options[:current_page] + options[:window] + 1).to_a

        (left_window_plus_one + inside_window_plus_each_sides + right_window_plus_one).uniq.sort.reject {|x| (x < 1) || (x > options[:total_pages])}
      end
      private :relevant_pages

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

        # There is a logging subscriber
        # and we don't want it to log render_partial
        # It is threadsafe, but might not repress logging
        # consistently in a high-load environment
        if subscriber
          unless defined? subscriber.render_partial_with_logging
            class << subscriber
              alias_method :render_partial_with_logging, :render_partial
              attr_accessor :render_without_logging
              # ugly hack to make a renderer where
              # we can turn logging on or off
              def render_partial(event)
                render_partial_with_logging(event) unless render_without_logging
              end
            end
          end

          subscriber.render_without_logging = true
          ret = super @window_options.merge :paginator => self
          subscriber.render_without_logging = false

          ret
        else
          super @window_options.merge :paginator => self
        end
      end

      # delegates view helper methods to @template
      def method_missing(name, *args, &block)
        @template.respond_to?(name) ? @template.send(name, *args, &block) : super
      end
      private :method_missing

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
          @page == @options[:total_pages]
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
          @options[:total_pages] - @page < @options[:right]
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
