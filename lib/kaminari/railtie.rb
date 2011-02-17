require 'rails'
require 'action_view'
require File.join(File.dirname(__FILE__), 'helpers')

module Kaminari
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'paginatablize' do |app|
      if defined? ::ActiveRecord
        require File.join(File.dirname(__FILE__), 'active_record')
        ::ActiveRecord::Base.send :include, Kaminari::ActiveRecord
      end
      if defined? ::Mongoid
        require File.join(File.dirname(__FILE__), 'mongoid')
        require File.join(File.dirname(__FILE__), 'mongoid/criteria')
        require File.join(File.dirname(__FILE__), 'mongoid/document')
        ::Mongoid::Criteria.send :include, Kaminari::Mongoid::Criteria
        ::Mongoid::Document.send :include, Kaminari::Mongoid::Document
      end
      ::ActionView::Base.send :include, Kaminari::Helpers
    end
  end
end
