module Kaminari
  module Helpers
    class Tag
      def initialize(renderer, options = {})
        @renderer, @options = renderer, renderer.options.merge(options)
      end

      def to_s(locals = {})
        @renderer.render :partial => "kaminari/#{self.class.name.demodulize.underscore}", :locals => @options.merge(locals)
      end

      private
      def page_url_for(page)
        @renderer.url_for @renderer.params.merge(:page => (page <= 1 ? nil : page))
      end
    end

    class PrevSpan < Tag
    end

    class PrevLink < Tag
      def to_s
        super :prev_url => page_url_for(@options[:current_page] - 1)
      end
    end

    class NextSpan < Tag
    end

    class NextLink < Tag
      def to_s
        super :next_url => page_url_for(@options[:current_page] + 1)
      end
    end

    class PageLink < Tag
      def to_s
        super :page_url => page_url_for(@options[:page])
      end
    end

    class CurrentPage < Tag
      def to_s
        super :page_url => page_url_for(@options[:page])
      end
    end

    class FirstPageLink < PageLink
    end

    class LastPageLink < PageLink
    end

    class TruncatedSpan < Tag
    end

    class Paginator < Tag
    end

    class PaginationRenderer
      attr_reader :options

      def initialize(template, options)
        @template, @options = template, options
        @left, @window, @right = (options[:left] || options[:outer_window] || 1), (options[:window] || options[:inner_window] || 4), (options[:right] || options[:outer_window] || 1)
      end

      def tagify
        num_pages, current_page, left, window, right = @options[:num_pages], @options[:current_page], @left, @window, @right

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

      def to_s
        suppress_logging_render_partial do
          @template.content_for :kaminari_paginator_tags, tagify.join("\n").html_safe
          Paginator.new(self).to_s
        end
      end

      private
      def method_missing(meth, *args, &blk)
        @template.send meth, *args, &blk
      end

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
    end

    def paginate(scope, options = {}, &block)
      PaginationRenderer.new self, options.reverse_merge(:current_page => scope.current_page, :num_pages => scope.num_pages)
    end
  end
end
