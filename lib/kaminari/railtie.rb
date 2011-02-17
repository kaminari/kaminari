require 'rails'
require 'action_view'
require File.join(File.dirname(__FILE__), 'active_record') if defined? ::ActiveRecord
require File.join(File.dirname(__FILE__), 'mongoid') if defined? ::Mongoid
require File.join(File.dirname(__FILE__), 'mongoid/criteria') if defined? ::Mongoid::Criteria
require File.join(File.dirname(__FILE__), 'mongoid/document') if defined? ::Mongoid::Document
require File.join(File.dirname(__FILE__), 'helpers')

module Kaminari
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'paginatablize' do |app|
      ::ActiveRecord::Base.send :include, Kaminari::ActiveRecord if defined? ::ActiveRecord::Base
      ::ActionView::Base.send :include, Kaminari::Helpers
      ::Mongoid::Criteria.send :include, Kaminari::Mongoid::Criteria if defined? ::Mongoid::Criteria
      ::Mongoid::Document.send :include, Kaminari::Mongoid::Document if defined? ::Mongoid::Document
    end
  end
end
