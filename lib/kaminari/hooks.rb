module Kaminari
  class Hooks
    def self.init
      ActiveSupport.on_load(:active_record) do
        require 'kaminari/models/active_record_extension'
        ::ActiveRecord::Base.send :include, Kaminari::ActiveRecordExtension
      end

      begin; require 'mongoid'; rescue LoadError; end
      if defined? ::Mongoid
        require 'kaminari/models/mongoid_extension'
        ::Mongoid::Document.send :include, Kaminari::MongoidExtension::Document
      end

      require 'kaminari/models/array_extension'

      ActiveSupport.on_load(:action_view) do
        ::ActionView::Base.send :include, Kaminari::ActionViewExtension
      end
    end
  end
end
