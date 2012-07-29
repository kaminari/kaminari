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
        @theme = @options[:theme] ? "#{@options.delete(:theme)}/" : ''
        @params = @options[:params] ? template.params.merge(@options.delete :params) : template.params
      end

      def to_s(locals = {}) #:nodoc:
        @template.render :partial => "kaminari/#{@theme}#{self.class.name.demodulize.underscore}", :locals => @options.merge(locals)
      end

      def page_url_for(page)
        current_page_params_as_query_string = @param_name.to_s + '=' + (page <= 1 ? nil : page).to_s
        current_page_params_as_hash = Rack::Utils.parse_nested_query(current_page_params_as_query_string)
        @template.url_for Kaminari::Helpers.recursive_symbolize_keys(Kaminari::Helpers.recursive_merge(@params, current_page_params_as_hash))
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
        @options[:total_pages]
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

    def self.recursive_merge(hash, other)  #:nodoc:
      res = hash.clone
      other.each do |key, other_value|
        value = res[key]
        if value.is_a?(Hash) && other_value.is_a?(Hash)
          res[key] = recursive_merge(value, other_value)
        else
          res[key] = other_value
        end
      end
      res
    end

    def self.recursive_symbolize_keys(hash)  #:nodoc:
      res = Hash.new
      hash.each do |key, value|
        res[key] = value.is_a?(Hash) ? recursive_symbolize_keys(value) : value
      end
      res.symbolize_keys
    end

  end
end
