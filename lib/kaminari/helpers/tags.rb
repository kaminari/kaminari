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
        @output_buffer = @template.output_buffer
        if @output_buffer.nil?
          @output_buffer, @return_buffer = ActionView::OutputBuffer.new, true
        end
      end

      # render given block as a view template
      def render(&block)
        instance_eval &block if @options[:num_pages] > 1
        # return the output text only if the output_buffer was created inside this instance
        @return_buffer ? @output_buffer : nil
      end

      # enumerate each page providing PageProxy object as the block parameter
      def each_page
        1.upto(@options[:num_pages]) do |i|
          @page = i
          yield PageProxy.new(options, i, @last)
        end
      end

      %w[current_page first_page_link last_page_link page_link].each do |tag|
        eval <<-DEF
          def #{tag}_tag
            @last = #{tag.classify}.new @template, :page => @page
          end
        DEF
      end

      %w[prev_link prev_span next_link next_span truncated_span].each do |tag|
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
          @page <= @options[:left] + 1
        end

        # within the right outer window or not
        def right_outer?
          @options[:num_pages] - @page <= @options[:right]
        end

        # inside the inner window or not
        def inside_window?
          (@page - @options[:current_page]).abs <= @options[:window]
        end

        # The last rendered tag was "truncated" or not
        def was_truncated?
          @last.is_a? TruncatedSpan
        end
      end
    end

    # A page
    module Page
      include Renderable
      # target page number
      def page
        raise 'Override page with the actual page value to be a Page.'
      end
      def to_s(locals = {}) #:nodoc:
        super locals.merge(:page => page)
      end
    end

    # Tag that contains a link
    module Link
      include Renderable
      include Page
      # the link's href
      def url
        page_url_for page
      end
      def to_s(locals = {}) #:nodoc:
        super locals.merge(:url => url)
      end
    end

    # Tag that doesn't contain a link
    module NonLink
      include Renderable
    end

    # The "previous" page of the current page
    module Prev
      include Renderable
    end

    # "Previous" without link
    class PrevSpan < Tag
      include NonLink
      include Prev
    end

    # "Previous" with link
    class PrevLink < Tag
      include Link
      include Prev
      def page #:nodoc:
        @options[:current_page] - 1
      end
    end

    # The "next" page of the current page
    module Next
      include Renderable
    end

    # "Next" without link
    class NextSpan < Tag
      include NonLink
      include Next
    end

    # "Next" with link
    class NextLink < Tag
      include Link
      include Next
      def page #:nodoc:
        @options[:current_page] + 1
      end
    end

    # Link showing page number
    class PageLink < Tag
      include Page
      include Link
      def page #:nodoc:
        @options[:page]
      end
    end

    # Non-link tag showing the current page number
    class CurrentPage < Tag
      include Page
      include NonLink
      def page #:nodoc:
        @options[:page]
      end
    end

    # Link with page number that appears at the leftmost
    class FirstPageLink < PageLink
    end

    # Link with page number that appears at the rightmost
    class LastPageLink < PageLink
    end

    # Non-link tag that stands for skipped pages...
    class TruncatedSpan < Tag
      include NonLink
    end
  end
end
