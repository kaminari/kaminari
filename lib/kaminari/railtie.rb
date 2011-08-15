require 'rails'
# ensure ORMs are loaded *before* initializing Kaminari
begin; require 'mongoid'; rescue LoadError; end
begin; require 'mongo_mapper'; rescue LoadError; end
begin; require 'dm-core'; rescue LoadError; end

require 'kaminari/config'
require 'kaminari/helpers/action_view_extension'
require 'kaminari/helpers/paginator'
require 'kaminari/models/page_scope_methods'
require 'kaminari/models/configuration_methods'

module Kaminari
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'kaminari' do |app|
      ActiveSupport.on_load(:active_record) do
        require 'kaminari/models/active_record_extension'
        ::ActiveRecord::Base.send :include, Kaminari::ActiveRecordExtension
      end
      if defined? ::Mongoid
        require 'kaminari/models/mongoid_extension'
        ::Mongoid::Document.send :include, Kaminari::MongoidExtension::Document
        ::Mongoid::Criteria.send :include, Kaminari::MongoidExtension::Criteria
      end
      if defined? ::MongoMapper
        require 'kaminari/models/mongo_mapper_extension'
        ::MongoMapper::Document.send :include, Kaminari::MongoMapperExtension::Document
        ::Plucky::Query.send :include, Kaminari::PluckyCriteriaMethods
        ::Plucky::Query.send :include, Kaminari::PageScopeMethods
      end
      if defined? ::DataMapper
        require 'kaminari/models/data_mapper_extension'
        ::DataMapper::Model.send :include, Kaminari::DataMapperExtension::Model
        ::DataMapper::Collection.send :include, Kaminari::DataMapperExtension::Collection
      end
      require 'kaminari/models/array_extension'
      ActiveSupport.on_load(:action_view) do
        ::ActionView::Base.send :include, Kaminari::ActionViewExtension
      end
    end
  end
end
