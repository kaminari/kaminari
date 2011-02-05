require 'rails'
require 'active_record'
require File.join(File.dirname(__FILE__), 'active_record')

module Kaminari
  class Railtie < ::Rails::Railtie
    initializer 'paginatablize' do |app|
      ::ActiveRecord::Base.send :include, Kaminari::ActiveRecord
    end
  end
end
