module Kaminari
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'kaminari' do |app|
      Kaminari::Hooks.init!
    end
  end
end
