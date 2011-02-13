require File.join(File.dirname(__FILE__), 'tags')

module Kaminari
  module Helpers
    class PaginationRenderer
      attr_reader :options, :params

      def initialize(template, options) #:nodoc:
        @template, @options = template, options
        @params = options[:params] ? template.params.merge(options.delete :params) : template.params
        @left, @window, @right = (options[:left] || options[:outer_window] || 1), (options[:window] || options[:inner_window] || 4), (options[:right] || options[:outer_window] || 1)
      end

      def tagify_links #:nodoc:
        num_pages, current_page, left, window, right = @options[:num_pages], @options[:current_page], @left, @window, @right
        return [] if num_pages <= 1

        tags = []
        tags << (current_page > 1 ? PrevLink.new(self) : PrevSpan.new(self))
        1.upto(num_pages) do |i|
          if i == current_page
            tags << CurrentPage.new(self, :page => i)
          elsif (i <= left + 1) || ((num_pages - i) <= right) || ((i - current_page).abs <= window)
            case i
            when 1
              tags << FirstPageLink.new(self, :page => i)
            when num_pages
              tags << LastPageLink.new(self, :page => i)
            else
              tags << PageLink.new(self, :page => i)
            end
          else
            tags << TruncatedSpan.new(self) unless tags.last.is_a? TruncatedSpan
          end
        end
        tags << (num_pages > current_page ? NextLink.new(self) : NextSpan.new(self))
      end

      def partial_exists?(name) #:nodoc:
        resolver = context.instance_variable_get('@view_paths').first
        resolver.find_all(*args_for_lookup(name)).present?
      end

      def to_s #:nodoc:
        suppress_logging_render_partial do
          clear_content_for :kaminari_paginator_tags
          @template.content_for :kaminari_paginator_tags, tagify_links.join.html_safe
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

      # another dirty hack
      def clear_content_for(name)
        @template.instance_variable_get('@_content_for')[name] = ActiveSupport::SafeBuffer.new
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
