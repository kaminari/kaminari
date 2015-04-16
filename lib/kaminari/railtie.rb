module Kaminari
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'kaminari' do |_app|
      # load static non-evaluated extensions methods before they are called
      # (devised to load the Rails testing environment correctly)
      Kaminari::Hooks.before_init

      # evaluate dynamic extensions after Rails initialization 
      # to enable custom configuration for gem defined models
      config.after_initialize do
        Kaminari::Hooks.init
      end
    end
  end
end
