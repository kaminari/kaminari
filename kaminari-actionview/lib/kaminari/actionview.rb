# frozen_string_literal: true
require "kaminari/actionview/version"

ActiveSupport.on_load :action_view do
  require 'kaminari/helpers/helper_methods'
  ::ActionView::Base.send :include, Kaminari::Helpers::HelperMethods

  require 'kaminari/actionview/action_view_extension'
end
