module Kaminari
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'kaminari' do |_app|
      if Rails.env.test?
        ActiveSupport.on_load(:active_record) do
          ::ActiveRecord::Base.send :include, Kaminari::ConfigurationMethods
        end
      end

      config.after_initialize do
        Kaminari::Hooks.init
      end
    end
  end
end
