require 'rails'
require 'active_record'
require 'action_view'
require File.join(File.dirname(__FILE__), 'active_record')
require File.join(File.dirname(__FILE__), 'helpers')

module Kaminari
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'paginatablize' do |app|
      ::ActiveRecord::Base.send :include, Kaminari::ActiveRecord
      ::ActionView::Base.send :include, Kaminari::Helpers
    end
  end
end
