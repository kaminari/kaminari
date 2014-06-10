module Kaminari
  module Helpers
    PARAM_KEY_BLACKLIST = :authenticity_token, :commit, :utf8, :_method

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
        @param_name = @options.delete(:param_name) || Kaminari.config.param_name
        @theme = @options.delete(:theme)
        @views_prefix = @options.delete(:views_prefix)
        @params = template.params.except(*PARAM_KEY_BLACKLIST).merge(@options.delete(:params) || {})
      end

      def to_s(locals = {}) #:nodoc:
        @template.render :partial => partial_path, :locals => @options.merge(locals), :formats => [:html]
      end

      def page_url_for(page)
        @template.url_for params_for(page).merge(:only_path => true)
      end

      private

      def params_for(page)
        page_params = Rack::Utils.parse_nested_query("#{@param_name}=#{page}")
        page_params = @params.with_indifferent_access.deep_merge(page_params)

        if page <= 1
          # This converts a hash:
          #   from: {other: "params", page: 1}
          #     to: {other: "params", page: nil}
          #   (when @param_name == "page")
          #
          #   from: {other: "params", user: {name: "yuki", page: 1}}
          #     to: {other: "params", user: {name: "yuki", page: nil}}
          #   (when @param_name == "user[page]")
          @param_name.to_s.scan(/\w+/)[0..-2].inject(page_params){|h, k| h[k] }[$&] = nil
        end

        page_params
      end

      def partial_path
        [
         @views_prefix,
         "kaminari",
         @theme,
         self.class.name.demodulize.underscore
        ].compact.join("/")
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
  end
end
