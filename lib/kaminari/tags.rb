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
      def initialize(renderer, options = {}) #:nodoc:
        @renderer, @options = renderer, renderer.options.merge(options)
      end

      def to_s(locals = {}) #:nodoc:
        @renderer.render :partial => find_template, :locals => @options.merge(locals)
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
          return "kaminari/#{klass.template_filename}" if @renderer.partial_exists? klass.template_filename
        end
        "kaminari/#{self.class.template_filename}"
      end

      def page_url_for(page)
        @renderer.url_for @renderer.params.merge(:page => (page <= 1 ? nil : page))
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

    # The container tag
    class Paginator < Tag
      include Renderable

      def to_s(locals = {}) #:nodoc:
        super locals.merge(:renderer => @renderer)
      end
    end
  end
end
