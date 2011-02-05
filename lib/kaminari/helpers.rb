module Kaminari
  module Helpers
    class Tag
      def initialize(renderer)
        @renderer = renderer
      end

      def method_missing(meth, *args, &blk)
        @renderer.send meth, *args, &blk
      end
    end

    class PrevLink < Tag
      def to_s
        content_tag :span, :class => 'prev' do
          link_to_if (current_page > 1), prev_label, page_url_for(current_page - 1), :class => 'prev', :rel => 'prev'
        end
      end
    end

    class NextLink < Tag
      def to_s
        content_tag :span, :class => 'prev' do
          link_to_if (current_page < num_pages), next_label, page_url_for(current_page + 1), :class => 'next', :rel => 'next'
        end
      end
    end

    class PageLink < Tag
      def initialize(page, renderer)
        super renderer
        @page = page
      end

      def to_s
        content_tag :span, :class => "#{style}#{@page == current_page ? ' current' : ''}" do
          link_to_unless_current @page.to_s, page_url_for(@page)
        end
      end
    end

    #TODO
    class FirstPageLink < Tag
    end

    #TODO
    class LastPageLink < Tag
    end

    #TODO
    class CurrentPage < Tag
    end

    class TruncatedSpan < Tag
      def to_s
        content_tag :span, truncate, :class => style
      end
    end

    class PaginationRenderer
      attr_reader :prev_label, :next_label, :left, :window, :right, :truncate, :style, :current_page, :num_pages

      def initialize(scope, options, template)
        @scope, @template = scope, template
        @prev_label, @next_label, @left, @window, @right, @truncate, @style = (options[:prev] || '&laquo; Prev'.html_safe), (options[:next] || 'Next &raquo;'.html_safe), (options[:left] || 2), (options[:window] || 5), (options[:right] || 2), (options[:truncate] || '...'), (options[:style] || 'page')
        @current_page, @num_pages = scope.current_page, scope.num_pages
      end

      def to_s
        content_tag :div, :class => 'pagination' do
          [].tap {|tags|
            tags << PrevLink.new(self)
            (1..num_pages).each do |i|
              if (i <= left) || ((num_pages - i) < right) || ((i - current_page).abs < window)
                tags << PageLink.new(i, self)
              else
                tags << TruncatedSpan.new(self) unless tags.last.is_a? TruncatedSpan
              end
            end
            tags << NextLink.new(self)
          }.join("\n").html_safe
        end
      end

      private
      def page_url_for(page)
        @template.url_for params.merge(:page => (page <= 1 ? nil : page))
      end

      def method_missing(meth, *args, &blk)
        @template.send meth, *args, &blk
      end
    end

    def paginate(scope, options = {}, &block)
      PaginationRenderer.new scope, options, self
    end
  end
end
