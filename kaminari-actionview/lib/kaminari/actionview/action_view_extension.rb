# frozen_string_literal: true

require 'action_view/log_subscriber'
require 'action_view/context'

require 'kaminari/helpers/paginator'

module Kaminari
  # = Helpers
  module ActionViewExtension
    # Monkey-patching AV::LogSubscriber not to log each render_partial
    module LogSubscriberSilencer
      def render_partial(*)
        super unless Thread.current[:kaminari_rendering]
      end
    end
  end
end

# so that this instance can actually "render"
::Kaminari::Helpers::Paginator.include ::ActionView::Context

ActionView::LogSubscriber.prepend Kaminari::ActionViewExtension::LogSubscriberSilencer
