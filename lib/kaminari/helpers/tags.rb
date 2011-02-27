module Kaminari
  module Helpers
    # A tag stands for an HTML tag inside the paginator.
    # Basically, a tag has its own partial template file, so every tag can be
    # rendered into String using its partial template.
    #
    # The template file should be placed in your app/views/kaminari/ directory
    # with underscored class name (besides the "Tag" class. Tag is an abstract
    # class, so _tag parital is not needed).
    #   e.g.)  PrevLink  ->  app/views/kaminari/_prev_link.html.erb
    #
    # When no matching template were found in your app, the engine's pre
    # installed template will be used.
    #   e.g.)  Paginator  ->  $GEM_HOME/kaminari-x.x.x/app/views/kaminari/_paginator.html.erb
    class Tag
      def initialize(template, options = {}) #:nodoc:
        @template, @options = template, options.dup
        @param_name = @options.delete(:param_name)
        @params = @options[:params] ? template.params.merge(@options.delete :params) : template.params
      end

      def to_s(locals = {}) #:nodoc:
        @template.render :partial => "kaminari/#{self.class.name.demodulize.underscore}", :locals => @options.merge(locals)
      end

      def page_url_for(page)
        @template.url_for @template.params.merge(@param_name => (page <= 1 ? nil : page))
      end
    end

    # The container tag
    class Paginator < Tag
      def initialize(template, options) #:nodoc:
        @window_options = {}.tap do |h|
          h[:window] = options.delete(:window) || options.delete(:inner_window) || 4
          outer_window = options.delete(:outer_window)
          h[:left] = options.delete(:left) || outer_window || 0
          h[:right] = options.delete(:right) || outer_window || 0
        end
        @template, @options = template, options
        # so that this instance can actually "render". Black magic?
        @output_buffer = ActionView::OutputBuffer.new
      end

      # render given block as a view template
      def render(&block)
        instance_eval &block if @options[:num_pages] > 1
        @output_buffer
      end

      # enumerate each page providing PageProxy object as the block parameter
      def each_page
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
        super @window_options.merge(@options).merge :paginator => self
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
          (@page - @options[:current_page]).abs <= @options[:window]
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

        def <=>(other)
          to_i <=> other.to_i
        end
      end
    end

    # Tag that contains a link
    module Link
      # target page number
      def page
        raise 'Override page with the actual page value to be a Page.'
      end
      # the link's href
      def url
        page_url_for page
      end
      def to_s(locals = {}) #:nodoc:
        super locals.merge(:url => url)
      end
    end

    # A page
    class Page < Tag
      include Link
      # target page number
      def page
        @options[:page]
      end
      def to_s(locals = {}) #:nodoc:
        super locals.merge(:page => page)
      end
    end

    # Link with page number that appears at the leftmost
    class FirstPage < Tag
      include Link
      def page #:nodoc:
        1
      end
    end

    # Link with page number that appears at the rightmost
    class LastPage < Tag
      include Link
      def page #:nodoc:
        @options[:num_pages]
      end
    end

    # The "previous" page of the current page
    class PrevPage < Tag
      include Link
      def page #:nodoc:
        @options[:current_page] - 1
      end
    end

    # The "next" page of the current page
    class NextPage < Tag
      include Link
      def page #:nodoc:
        @options[:current_page] + 1
      end
    end

    # Non-link tag that stands for skipped pages...
    class Gap < Tag
    end
  end
end
