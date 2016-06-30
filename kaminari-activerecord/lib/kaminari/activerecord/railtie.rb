module Kaminari
  module ActiveRecord
    class Railtie < ::Rails::Railtie #:nodoc:
      initializer 'kaminari-activerecord' do
        ActiveSupport.on_load :active_record do
          require 'kaminari/activerecord/active_record_extension'
          ::ActiveRecord::Base.send :include, Kaminari::ActiveRecordExtension
        end
      end
    end
  end
end
