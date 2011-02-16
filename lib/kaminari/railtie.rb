require 'rails'
require 'active_record'
require 'action_view'
require 'mongoid'
require File.join(File.dirname(__FILE__), 'active_record')
require File.join(File.dirname(__FILE__), 'helpers')
require File.join(File.dirname(__FILE__), 'mongoid')

module Kaminari
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'paginatablize' do |app|
      ::ActiveRecord::Base.send :include, Kaminari::ActiveRecord
      ::ActionView::Base.send :include, Kaminari::Helpers
      ::Mongoid::Document.send :include, Kaminari::Mongoid
    end
  end
end
