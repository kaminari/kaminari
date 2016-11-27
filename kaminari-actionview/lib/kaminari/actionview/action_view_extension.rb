# frozen_string_literal: true
require 'action_view'
require 'action_view/log_subscriber'
require 'action_view/context'

module Kaminari
  # = Helpers
  module ActionViewExtension
    # Monkey-patching AV::LogSubscriber not to log each render_partial
    module LogSubscriberSilencer
      def render_partial(*)
        super unless Thread.current[:kaminari_rendering]
      end
    end

    module PaginatorExtension
      # so that this instance can actually "render"
      include ::ActionView::Context
    end
    ::Kaminari::Helpers::Paginator.send :include, PaginatorExtension
  end
end

ActionView::LogSubscriber.send :prepend, Kaminari::ActionViewExtension::LogSubscriberSilencer
