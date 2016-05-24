module Kaminari
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'kaminari' do
      Kaminari::Hooks.init
    end
  end
end
