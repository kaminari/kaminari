module Kaminari
  module ActionView
    class Railtie < ::Rails::Railtie #:nodoc:
      initializer 'kaminari-actionview' do
        ActiveSupport.on_load :action_view do
          require 'kaminari/actionview/action_view_extension'
          ::ActionView::Base.send :include, Kaminari::ActionViewExtension
        end
      end
    end
  end
end
