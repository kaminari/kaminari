# frozen_string_literal: true

module Kaminari
  module Helpers
    PARAM_KEY_EXCEPT_LIST = [:authenticity_token, :commit, :utf8, :_method, :script_name, :original_script_name,
                             :subdomain, :domain, :tld_length, :host, :port, :protocol, :anchor, :trailing_slash, :params, :path_params].freeze

    # A tag stands for an HTML tag inside the paginator.
    # Basically, a tag has its own partial template file, so every tag can be
    # rendered into String using its partial template.
    #
    # The template file should be placed in your app/views/kaminari/ directory
    # with underscored class name (besides the "Tag" class. Tag is an abstract
    # class, so _tag partial is not needed).
    #   e.g.)  PrevLink  ->  app/views/kaminari/_prev_link.html.erb
    #
    # When no matching templates were found in your app, the engine's pre
    # installed template will be used.
    #   e.g.)  Paginator  ->  $GEM_HOME/kaminari-x.x.x/app/views/kaminari/_paginator.html.erb
    class Tag
      # A page number that is unlikely to appear in any URL, which stands in for the actual page number in the cached URL
      PAGE_PLACEHOLDER = rand(10**17...10**18)

      def initialize(template, params: nil, param_name: nil, theme: nil, views_prefix: nil, internal_params: nil, internal_url_cache: nil, internal_partial_cache: nil, **options) #:nodoc:
        @template, @theme, @views_prefix, @options = template, theme, views_prefix, options
        @param_name = param_name || Kaminari.config.param_name
        @url_cache, @partial_cache = internal_url_cache, internal_partial_cache

        if internal_params
          @params = internal_params
        else
          @params = template.params
          # @params in Rails 5 no longer inherits from Hash
          @params = if @params.respond_to?(:to_unsafe_h)
            @params.to_unsafe_h
          else
            @params.with_indifferent_access
          end
          @params.except!(*PARAM_KEY_EXCEPT_LIST)
          @params.merge! params if params
        end
      end

      def to_s(locals = {}) #:nodoc:
        formats = @template.respond_to?(:formats) ? @template.formats : Array(@template.params[:format])
        if @partial_cache && formats.include?(:html) && @template.respond_to?(:lookup_context)
          render_cached_partial @options.merge(locals)
        else
          formats += [:html] unless formats.include? :html
          @template.render partial: partial_path, locals: @options.merge(locals), formats: formats
        end
      end

      def page_url_for(page)
        @url_cache ? cached_page_url_for(page.to_i) : generate_page_url(page)
      end

      private

      # Looking up a partial template is costly, so the paginator looks up each partial only once, and then renders the
      # template directly in the same way as `render partial:` does.
      # This is done only when the formats already include :html, which means the formats that `to_s` would pass to
      # `render` are the same as the current ones, and so finding and rendering the template doesn't depend on the formats.
      def render_cached_partial(locals)
        path, keys = partial_path, locals.keys
        cached_keys, template = @partial_cache[path]
        unless template && (cached_keys == keys)
          template = @template.lookup_context.find(path, [], true, keys)
          @partial_cache[path] = [keys, template]
        end
        # `render partial:` in Action View 4 also puts the partial name into local_assigns (e.g. {gap: nil, ...})
        if ActionView::VERSION::MAJOR < 5
          name = File.basename(path).to_sym
          locals[name] = nil unless locals.key? name
        end

        ActiveSupport::Notifications.instrument('render_partial.action_view', identifier: template.identifier, layout: nil, locals: locals) do
          template.render(@template, locals) {|*name| @template._layout_for(*name) }
        end
      end

      def generate_page_url(page)
        params = params_for(page)
        params[:only_path] = true
        @template.url_for params
      end

      # Generating URLs is costly, so the paginator generates the URL only once with a placeholder page number,
      # and then builds the URL for each page by replacing the placeholder
      def cached_page_url_for(page)
        @url_cache.fetch(page) do
          url_template = @url_cache[:url_template]
          @url_cache[page] = if url_template && (page > 1)
            url_template.sub(PAGE_PLACEHOLDER.to_s, page.to_s)
          else
            generate_page_url(page).tap {|url| build_url_template(page, url) if url_template.nil? && (page > 1) }
          end
        end
      end

      # Use the URL with the placeholder only when it builds exactly the same URL as url_for does.
      # Otherwise (e.g. when the routes constrain the page number), fall back to calling url_for for each page.
      def build_url_template(page, url)
        url_template = begin
          generate_page_url PAGE_PLACEHOLDER
        rescue StandardError
          nil
        end
        @url_cache[:url_template] = url_template && (url_template.scan(PAGE_PLACEHOLDER.to_s).size == 1) && (url_template.sub(PAGE_PLACEHOLDER.to_s, page.to_s) == url) ? url_template : false
      end

      def params_for(page)
        if (@param_name == :page) || !@param_name.to_s.include?('[')
          page_val = !Kaminari.config.params_on_first_page && (page <= 1) ? nil : page
          @params[@param_name] = page_val
          @params
        else
          page_params = Rack::Utils.parse_nested_query("#{@param_name}=#{page}")
          page_params = @params.deep_merge(page_params)

          if !Kaminari.config.params_on_first_page && (page <= 1)
            # This converts a hash:
            #   from: {other: "params", page: 1}
            #     to: {other: "params", page: nil}
            #   (when @param_name == "page")
            #
            #   from: {other: "params", user: {name: "yuki", page: 1}}
            #     to: {other: "params", user: {name: "yuki", page: nil}}
            #   (when @param_name == "user[page]")
            @param_name.to_s.scan(/[\w.]+/)[0..-2].inject(page_params){|h, k| h[k] }[$&] = nil
          end

          page_params
        end
      end

      def partial_path
        "#{@views_prefix}/kaminari/#{@theme}/#{self.class.name.demodulize.underscore}".gsub('//', '/')
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
        locals[:url] = url
        super locals
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
        locals[:page] = page
        super locals
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

      # TODO: Remove this initializer before 1.3.0.
      def initialize(template, params: {}, param_name: nil, theme: nil, views_prefix: nil, **options) #:nodoc:
        # params in Rails 5 may not be a Hash either,
        # so it must be converted to a Hash to be merged into @params
        if params && params.respond_to?(:to_unsafe_h)
          Kaminari.deprecator.warn 'Explicitly passing params to helpers could be omitted.'
          params = params.to_unsafe_h
        end

        super(template, params: params, param_name: param_name, theme: theme, views_prefix: views_prefix, **options)
      end

      def page #:nodoc:
        @options[:current_page] - 1
      end
    end

    # The "next" page of the current page
    class NextPage < Tag
      include Link

      # TODO: Remove this initializer before 1.3.0.
      def initialize(template, params: {}, param_name: nil, theme: nil, views_prefix: nil, **options) #:nodoc:
        # params in Rails 5 may not be a Hash either,
        # so it must be converted to a Hash to be merged into @params
        if params && params.respond_to?(:to_unsafe_h)
          Kaminari.deprecator.warn 'Explicitly passing params to helpers could be omitted.'
          params = params.to_unsafe_h
        end

        super(template, params: params, param_name: param_name, theme: theme, views_prefix: views_prefix, **options)
      end

      def page #:nodoc:
        @options[:current_page] + 1
      end
    end

    # Non-link tag that stands for skipped pages...
    class Gap < Tag
    end
  end
end
