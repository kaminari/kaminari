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
    # When no template were found in your app, finally the engine's pre insatalled
    # template will be used.
    #   e.g.)  Paginator  ->  $GEM_HOME/kaminari-x.x.x/app/views/kaminari/_paginator.html.erb
    class Tag
      def self.template_filename #:nodoc:
        name.demodulize.underscore
      end

      def initialize(renderer, options = {}) #:nodoc:
        @renderer, @options = renderer, renderer.options.merge(options)
      end

      def to_s(locals = {}) #:nodoc:
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

    # "Previous" without link
    class PrevSpan < Tag
    end

    # "Previous" with link
    class PrevLink < Tag
      def to_s #:nodoc:
        super :prev_url => page_url_for(@options[:current_page] - 1)
      end
    end

    # "Next" without link
    class NextSpan < Tag
    end

    # "Next" with link
    class NextLink < Tag
      def to_s #:nodoc:
        super :next_url => page_url_for(@options[:current_page] + 1)
      end
    end

    # A link showing page number
    class PageLink < Tag
      def to_s #:nodoc:
        super :page_url => page_url_for(@options[:page])
      end
    end

    # A non-link tag showing the current page number
    class CurrentPage < Tag
      def to_s #:nodoc:
        super :page_url => page_url_for(@options[:page])
      end
    end

    # A link with page number that appears at the leftmost
    class FirstPageLink < PageLink
    end

    # A link with page number that appears at the rightmost
    class LastPageLink < PageLink
    end

    # A non-link tag that stands for skipped pages...
    class TruncatedSpan < Tag
    end

    # The container tag
    class Paginator < Tag
    end
  end
end
