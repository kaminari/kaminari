require "kaminari/actionview/version"

ActiveSupport.on_load :action_view do
  require 'kaminari/actionview/action_view_extension'
  ::ActionView::Base.send :include, Kaminari::ActionViewExtension
end
