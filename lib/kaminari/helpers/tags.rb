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
    # If the template file does not exist, it falls back to ancestor classes.
    #   e.g.)  FirstPageLink  ->  app/views/kaminari/_first_page_link.html.erb
    #                         ->  app/views/kaminari/_page_link.html.erb
    #
    # When no matching template were found in your app, finally the engine's pre
    # installed template will be used.
    #   e.g.)  Paginator  ->  $GEM_HOME/kaminari-x.x.x/app/views/kaminari/_paginator.html.erb
    class Tag
      def initialize(template, options = {}) #:nodoc:
        @template, @options = template, template.options.merge(options)
        @param_name = @options.delete :param_name
      end

      def to_s(locals = {}) #:nodoc:
        @template.render :partial => find_template, :locals => @options.merge(locals)
      end

      private
      def self.ancestor_renderables
        arr = []
        ancestors.each do |klass|
          return arr if klass == Tag
          arr << klass if klass != Renderable
        end
      end

      # OMG yet another super dirty hack
      # this method finds
      #   1. a template for the given class from app/views
      #   2. a template for its parent class from app/views
      #   3. the default one inside the engine
      def find_template
        self.class.ancestor_renderables.each do |klass|
          return "kaminari/#{klass.template_filename}" if @template.partial_exists? klass.template_filename
        end
        "kaminari/#{self.class.template_filename}"
      end

      def page_url_for(page)
        @template.url_for @template.params.merge(@param_name => (page <= 1 ? nil : page))
      end
    end

    module Renderable #:nodoc:
      def self.included(base) #:nodoc:
        base.extend ClassMethods
      end
      module ClassMethods #:nodoc:
        def template_filename #:nodoc:
          name.demodulize.underscore
        end
        def included(base) #:nodoc:
          base.extend Renderable::ClassMethods
        end
      end
    end

    # The container tag
    class Paginator < Tag
      include Renderable
      attr_reader :options

      def initialize(template, window_options) #:nodoc:
        @template, @options = template, window_options.reverse_merge(template.options)
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
          yield PageProxy.new(options, i, @last)
        end
      end

      def page_tag(page)
        @last = Page.new @template, :page => page
      end

      %w[first_page prev_page next_page last_page gap].each do |tag|
        eval <<-DEF
          def #{tag}_tag
            @last = #{tag.classify}.new @template
          end
        DEF
      end

      def to_s(window_options = {}) #:nodoc:
        super window_options.merge :paginator => self
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
      include Renderable
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
      include Renderable
    end
  end
end
