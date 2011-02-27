require File.join(File.dirname(__FILE__), 'tags')

module Kaminari
  module Helpers
    # The main class that controlls the whole process
    class PaginationRenderer
      def initialize(template, options) #:nodoc:
        @template, @options = template, options
      end

      def to_s #:nodoc:
        suppress_logging_render_partial do
          Paginator.new(@template, @options).to_s
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
