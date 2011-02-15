require File.join(File.dirname(__FILE__), 'tags')

module Kaminari
  module Helpers
    class PaginationRenderer
      attr_reader :options, :params, :left, :window, :right

      def initialize(template, options) #:nodoc:
        @template, @options = template, options
        # so that this Renderer instance can actually "render". Black magic?
        @output_buffer = @template.instance_variable_get('@output_buffer')
        @params = options[:params] ? template.params.merge(options.delete :params) : template.params
        @left, @window, @right = (options[:left] || options[:outer_window] || 1), (options[:window] || options[:inner_window] || 4), (options[:right] || options[:outer_window] || 1)
      end

      %w[current_page first_page_link last_page_link page_link].each do |tag|
        eval <<-DEF
          def #{tag}_tag
            @last = #{tag.classify}.new self, :page => @page
          end
        DEF
      end

      %w[prev_link prev_span next_link next_span truncated_span].each do |tag|
        eval <<-DEF
          def #{tag}_tag
            @last = #{tag.classify}.new self
          end
        DEF
      end

      def each_page
        1.upto(@options[:num_pages]) do |i|
          @page = i
          yield PageProxy.new(self, i, @last)
        end
      end

      def compose_tags(&block) #:nodoc:
        instance_eval &block if @options[:num_pages] > 1
      end

      def partial_exists?(name) #:nodoc:
        resolver = context.instance_variable_get('@view_paths').first
        resolver.find_all(*args_for_lookup(name)).present?
      end

      def to_s #:nodoc:
        suppress_logging_render_partial do
          Paginator.new(self).to_s
        end
      end

      private
      def context
        @template.instance_variable_get('@lookup_context')
      end

      def args_for_lookup(name)
        if (method = context.method :args_for_lookup).arity == 3
          # 3.0
          method.call name, 'kaminari', true
        else
          # 3.1
          method.call name, 'kaminari', true, []
        end
      end

      def method_missing(meth, *args, &blk)
        @template.send meth, *args, &blk
      end

      # dirty hack
      def suppress_logging_render_partial(&blk)
        if subscriber = ActionView::LogSubscriber.log_subscribers.detect {|ls| ls.is_a? ActionView::LogSubscriber}
          class << subscriber
            alias_method :render_partial_with_logging, :render_partial
            # do nothing
            def render_partial(event)
            end
          end
          ret = blk.call
          class << subscriber
            alias_method :render_partial, :render_partial_with_logging
            undef :render_partial_with_logging
          end
          ret
        else
          blk.call
        end
      end

      class PageProxy
        def initialize(renderer, page, last)
          @renderer, @page, @last = renderer, page, last
        end

        def current?
          @page == @renderer.options[:current_page]
        end

        def first?
          @page == 1
        end

        def last?
          @page == @renderer.options[:num_pages]
        end

        def left_outer?
          @page <= @renderer.left + 1
        end

        def right_outer?
          @renderer.options[:num_pages] - @page <= @renderer.right
        end

        def inside_window?
          (@page - @renderer.options[:current_page]).abs <= @renderer.window
        end

        def was_truncated?
          @last.is_a? TruncatedSpan
        end
      end
    end

    # = Helpers
    #
    # A helper that renders the pagination links.
    #
    #   <%= paginate @articles %>
    #
    # ==== Options
    # * <tt>:window</tt> - The "inner window" size (2 by default).
    # * <tt>:outer_window</tt> - The "outer window" size (1 by default).
    # * <tt>:left</tt> - The "left outer window" size (1 by default).
    # * <tt>:right</tt> - The "right outer window" size (1 by default).
    # * <tt>:params</tt> - url_for parameters for the links (:controller, :action, etc.)
    # * <tt>:remote</tt> - Ajax? (false by default)
    # * <tt>:ANY_OTHER_VALUES</tt> - Any other hash key & values would be directly passed into each tag as :locals value.
    def paginate(scope, options = {}, &block)
      PaginationRenderer.new self, options.reverse_merge(:current_page => scope.current_page, :num_pages => scope.num_pages, :per_page => scope.limit_value, :remote => false)
    end
  end
end
