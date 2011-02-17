require 'rails'
require 'action_view'
require File.join(File.dirname(__FILE__), 'active_record') if defined? ::ActiveRecord
require File.join(File.dirname(__FILE__), 'mongoid') if defined? ::Mongoid
require File.join(File.dirname(__FILE__), 'helpers')
require File.join(File.dirname(__FILE__), 'mongoid')

module Kaminari
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'paginatablize' do |app|
      ::ActiveRecord::Base.send :include, Kaminari::ActiveRecord if defined? ::ActiveRecord::Base
      ::ActionView::Base.send :include, Kaminari::Helpers
      ::Mongoid::Document.send :include, Kaminari::Mongoid if defined? ::Mongoid::Document
    end
  end
end
