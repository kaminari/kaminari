module Kaminari
  class Hooks
    def self.init
      ActiveSupport.on_load(:active_record) do
        require 'kaminari/models/active_record_extension'
        ::ActiveRecord::Base.send :include, Kaminari::ActiveRecordExtension
      end

      begin; require 'data_mapper'; rescue LoadError; end
      if defined? ::DataMapper
        require 'dm-aggregates'
        require 'kaminari/models/data_mapper_extension'
        ::DataMapper::Collection.send :include, Kaminari::DataMapperExtension::Collection
        ::DataMapper::Model.append_extensions Kaminari::DataMapperExtension::Model
        # ::DataMapper::Model.send :extend, Kaminari::DataMapperExtension::Model
      end

      begin; require 'mongoid'; rescue LoadError; end
      if defined? ::Mongoid
        require 'kaminari/models/mongoid_extension'
        ::Mongoid::Criteria.send :include, Kaminari::MongoidExtension::Criteria
        ::Mongoid::Document.send :include, Kaminari::MongoidExtension::Document
      end

      ActiveSupport.on_load(:mongo_mapper) do
        require 'kaminari/models/mongo_mapper_extension'
        ::MongoMapper::Document.send :include, Kaminari::MongoMapperExtension::Document
        ::Plucky::Query.send :include, Kaminari::PluckyCriteriaMethods
      end

      # Rails 3.0.x fails to load helpers in Engines (?)
      if defined?(::ActionView) && ::ActionPack::VERSION::STRING < '3.1'
        ActiveSupport.on_load(:action_view) do
          require 'kaminari/helpers/action_view_extension'
          ::ActionView::Base.send :include, Kaminari::ActionViewExtension
        end
      end
      require 'kaminari/models/array_extension'
    end
  end
end
