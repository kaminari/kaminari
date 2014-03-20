# require 'rails/all'
require 'action_controller/railtie'
require 'action_view/railtie'

require 'fake_app/active_record/config' if defined? ActiveRecord
require 'fake_app/data_mapper/config' if defined? DataMapper
require 'fake_app/mongoid/config' if defined? Mongoid
require 'fake_app/mongo_mapper/config' if defined? MongoMapper
# config
app = Class.new(Rails::Application)
app.config.secret_token = '3b7cd727ee24e8444053437c36cc66c4'
app.config.session_store :cookie_store, :key => '_myapp_session'
app.config.active_support.deprecation = :log
app.config.eager_load = false
# Rais.root
app.config.root = File.dirname(__FILE__)
Rails.backtrace_cleaner.remove_silencers!
app.initialize!

# routes
app.routes.draw do
  resources :users do
    resources :books
  end
end

#models
require 'fake_app/active_record/models' if defined? ActiveRecord
require 'fake_app/data_mapper/models' if defined? DataMapper
require 'fake_app/mongoid/models' if defined? Mongoid
require 'fake_app/mongo_mapper/models' if defined? MongoMapper

# controllers
class ApplicationController < ActionController::Base; end
class UsersController < ApplicationController
  def index
    @users = User.page params[:page]
    render :inline => <<-ERB
<%= @users.map(&:name).join("\n") %>
<%= paginate @users %>
ERB
  end
end

class BooksController < ApplicationController
  def index
    @books = User.find(params[:user_id]).books_authored.page params[:page]
    render :inline => <<-ERB
<span class="head"><%= rel_next_prev_link_tags @books %></span>
<%= @books.map(&:title).join("\n") %>
<%= paginate @books %>
ERB
  end
end

if defined? ActiveRecord
  class AddressesController < ApplicationController
    def index
      @addresses = User::Address.page params[:page]
      render :inline => <<-ERB
  <%= @addresses.map(&:street).join("\n") %>
  <%= paginate @addresses %>
  ERB
    end
  end
end

# helpers
Object.const_set(:ApplicationHelper, Module.new)
