module Kaminari #:nodoc:
  class Engine < ::Rails::Engine #:nodoc:
    initializer 'kaminari' do |_app|
      Kaminari::Hooks.init
    end
  end
end
