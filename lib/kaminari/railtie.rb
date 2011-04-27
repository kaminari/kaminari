require 'rails'
# ensure ORMs are loaded *before* initializing Kaminari
begin; require 'mongoid'; rescue LoadError; end
begin; require 'mongo_mapper'; rescue LoadError; end

require File.join(File.dirname(__FILE__), 'config')
require File.join(File.dirname(__FILE__), 'helpers/action_view_extension')
require File.join(File.dirname(__FILE__), 'helpers/paginator')
require File.join(File.dirname(__FILE__), 'models/page_scope_methods')
require File.join(File.dirname(__FILE__), 'models/configuration_methods')

module Kaminari
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'kaminari' do |app|
      ActiveSupport.on_load(:active_record) do
        require File.join(File.dirname(__FILE__), 'models/active_record_extension')
        ::ActiveRecord::Base.send :include, Kaminari::ActiveRecordExtension
      end
      if defined? ::Mongoid
        require File.join(File.dirname(__FILE__), 'models/mongoid_extension')
        ::Mongoid::Document.send :include, Kaminari::MongoidExtension::Document
        ::Mongoid::Criteria.send :include, Kaminari::MongoidExtension::Criteria
      end
      if defined? ::MongoMapper
        require File.join(File.dirname(__FILE__), 'models/mongo_mapper_extension')
        ::MongoMapper::Document.send :include, Kaminari::MongoMapperExtension::Document
        ::Plucky::Query.send :include, Kaminari::PluckyCriteriaMethods
        ::Plucky::Query.send :include, Kaminari::PageScopeMethods
      end
      require File.join(File.dirname(__FILE__), 'models/array_extension')
      ActiveSupport.on_load(:action_view) do
        ::ActionView::Base.send :include, Kaminari::ActionViewExtension
      end
    end
  end
end