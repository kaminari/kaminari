module Kaminari
  module Helpers
    class Tag
      def self.template_filename
        name.demodulize.underscore
      end

      def initialize(renderer, options = {})
        @renderer, @options = renderer, renderer.options.merge(options)
      end

      def to_s(locals = {})
        @renderer.render :partial => find_template, :locals => @options.merge(locals)
      end

      private
      # OMG yet another super dirty hack
      # this method finds
      #   1. a template for the given class from app/views
      #   2. a template for its parent class from app/views
      #   3. the default one inside the engine
      def find_template(klass = self.class)
        if @renderer.resolver.find_all(*args_for_lookup(klass)).present?
          "kaminari/#{klass.template_filename}"
        elsif (parent = klass.ancestors[1]) == Tag
          "kaminari/#{self.class.template_filename}"
        else
          find_template parent
        end
      end

      def args_for_lookup(klass)
        if (method = @renderer.context.method :args_for_lookup).arity == 3
          # 3.0
          method.call klass.template_filename, 'kaminari', true
        else
          # 3.1
          method.call klass.template_filename, 'kaminari', true, []
        end
      end

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
  end
end
