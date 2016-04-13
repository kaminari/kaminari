module Kaminari
  class Hooks
    def self.init
      ActiveSupport.on_load(:active_record) do
        require 'kaminari/models/active_record_extension'
        ::ActiveRecord::Base.send :include, Kaminari::ActiveRecordExtension
      end

      ## mongoid
      begin
        require 'kaminari/mongoid'
      rescue LoadError
        begin; require 'mongoid'; rescue LoadError; end
        if defined? ::Mongoid
          ActiveSupport::Deprecation.warn 'Kaminari Mongoid support has been extracted to a separate gem, and will be removed in the next 1.0 release. Please bundle kaminari-mongoid gem.'
          require 'kaminari/models/mongoid_extension'
          ::Mongoid::Document.send :include, Kaminari::MongoidExtension::Document
        end
      end

      require 'kaminari/models/array_extension'

      ActiveSupport.on_load(:action_view) do
        ::ActionView::Base.send :include, Kaminari::ActionViewExtension
      end
    end
  end
end
