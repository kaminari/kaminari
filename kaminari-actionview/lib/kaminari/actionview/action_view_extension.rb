# frozen_string_literal: true
require 'action_view'
require 'action_view/log_subscriber'
require 'action_view/context'

module Kaminari
  # = Helpers
  module ActionViewExtension
    module PaginatorExtension
      extend ActiveSupport::Concern

      # so that this instance can actually "render"
      include ::ActionView::Context

      included do
        undef :to_s
        # Redefining to_s not to log each render_partial
        def to_s #:nodoc:
          subscriber = ::ActionView::LogSubscriber.log_subscribers.detect {|ls| ls.is_a? ::ActionView::LogSubscriber}

          # There is a logging subscriber
          # and we don't want it to log render_partial
          # It is threadsafe, but might not repress logging
          # consistently in a high-load environment
          if subscriber
            unless defined? subscriber.render_partial_with_logging
              class << subscriber
                alias_method :render_partial_with_logging, :render_partial
                attr_accessor :render_without_logging
                # ugly hack to make a renderer where
                # we can turn logging on or off
                def render_partial(event)
                  render_partial_with_logging(event) unless render_without_logging
                end
              end
            end

            subscriber.render_without_logging = true
            ret = super @window_options.merge paginator: self
            subscriber.render_without_logging = false

            ret
          else
            super @window_options.merge paginator: self
          end
        end
      end
    end
    ::Kaminari::Helpers::Paginator.send :include, PaginatorExtension
  end
end
