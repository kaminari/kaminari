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

      ## mongo_mapper
      ActiveSupport.on_load(:mongo_mapper) do
        begin
          require 'kaminari/mongo_mapper'
        rescue LoadError
          ActiveSupport::Deprecation.warn p('Kaminari MongoMapper support has been extracted to a separate gem, and will be removed in the next 1.0 release. Please bundle kaminari-mongo_mapper gem.')
          require 'kaminari/models/mongo_mapper_extension'
          ::MongoMapper::Document.send :include, Kaminari::MongoMapperExtension::Document
          ::Plucky::Query.send :include, Kaminari::PluckyCriteriaMethods
        end
      end
      require 'kaminari/models/array_extension'

      ActiveSupport.on_load(:action_view) do
        ::ActionView::Base.send :include, Kaminari::ActionViewExtension
      end
    end
  end
end
