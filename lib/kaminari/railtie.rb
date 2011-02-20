require 'rails'
# ensure ORMs are loaded *before* initializing Kaminari
begin; require 'mongoid'; rescue LoadError; end

require File.join(File.dirname(__FILE__), 'helpers/action_view_extension')
require File.join(File.dirname(__FILE__), 'helpers/helpers')
require File.join(File.dirname(__FILE__), 'models/page_scope_methods')
require File.join(File.dirname(__FILE__), 'models/configuration_methods')

module Kaminari
  DEFAULT_PER_PAGE = 25 unless defined? ::Kaminari::DEFAULT_PER_PAGE
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
      ActiveSupport.on_load(:action_view) do
        ::ActionView::Base.send :include, Kaminari::ActionViewExtension
      end
    end
  end
end
