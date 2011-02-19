require 'rails'
require 'action_view'
# ensure ORMs are loaded *before* initializing Kaminari
begin; require 'active_record'; rescue LoadError; end
begin; require 'mongoid'; rescue LoadError; end

require File.join(File.dirname(__FILE__), 'helpers')

module Kaminari
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'kaminari' do |app|
      if defined? ::ActiveRecord
        require File.join(File.dirname(__FILE__), 'active_record_extension')
        ::ActiveRecord::Base.send :include, Kaminari::ActiveRecordExtension
      end
      if defined? ::Mongoid
        require File.join(File.dirname(__FILE__), 'mongoid_extension')
        ::Mongoid::Document.send :include, Kaminari::MongoidExtension::Document
        ::Mongoid::Criteria.send :include, Kaminari::MongoidExtension::Criteria
      end
      ::ActionView::Base.send :include, Kaminari::Helpers
    end
  end
end
