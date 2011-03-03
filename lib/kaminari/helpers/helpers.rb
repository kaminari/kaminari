require File.join(File.dirname(__FILE__), 'tags')

module Kaminari
  module Helpers
    # Wraps the template context and helps each tag render itselves
    class TemplateWrapper
      attr_reader :options, :params
      delegate :render, :url_for, :to => :@template

      def initialize(template, options) #:nodoc:
        @template, @options = template, options
        @params = options[:params] ? template.params.merge(options.delete :params) : template.params
      end

      def partial_exists?(name) #:nodoc:
        resolver = context.instance_variable_get('@view_paths').first
        resolver.find_all(*args_for_lookup(name)).present?
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
          method.call name, ['kaminari'], true, []
        end
      end
    end

    # The main class that controlls the whole process
    class PaginationRenderer
      def initialize(template, options) #:nodoc:
        @window_options = {}.tap do |h|
          h[:window] = options.delete(:window) || options.delete(:inner_window) || 4
          outer_window = options.delete(:outer_window)
          h[:left] = options.delete(:left) || outer_window || 1
          h[:right] = options.delete(:right) || outer_window || 1
        end
        @template = TemplateWrapper.new(template, options)
      end

      def to_s #:nodoc:
        suppress_logging_render_partial do
          Paginator.new(@template, @window_options).to_s
        end
      end

      private
      # dirty hack
      def suppress_logging_render_partial(&blk)
        if subscriber = ActionView::LogSubscriber.log_subscribers.detect {|ls| ls.is_a? ActionView::LogSubscriber}
          class << subscriber
            alias_method :render_partial_with_logging, :render_partial
            # do nothing
            def render_partial(event); end
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
  end
end
