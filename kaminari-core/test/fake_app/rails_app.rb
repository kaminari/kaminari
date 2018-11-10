# frozen_string_literal: true

# require 'rails/all'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'active_record/railtie' if defined? ActiveRecord

# config
class KaminariTestApp < Rails::Application
  config.secret_key_base = config.secret_token = '3b7cd727ee24e8444053437c36cc66c4'
  config.session_store :cookie_store, key: '_myapp_session'
  config.active_support.deprecation = :log
  config.eager_load = false
  # Rails.root
  config.root = File.dirname(__FILE__)
end
Rails.backtrace_cleaner.remove_silencers!
Rails.application.initialize!

# routes
Rails.application.routes.draw do
  resources :users do
    get 'index_text(.:format)', action: :index_text, on: :collection
  end
  resources :addresses do
    get 'page/:page', action: :index, on: :collection
  end
end

#models
require 'fake_app/active_record/models' if defined? ActiveRecord

# controllers
class ApplicationController < ActionController::Base; end
class UsersController < ApplicationController
  def index
    @users = User.page params[:page]
    render inline: <<-ERB
<%= @users.map(&:name).join("\n") %>
<%= link_to_previous_page @users, 'previous page', class: 'prev' %>
<%= link_to_next_page @users, 'next page', class: 'next' %>
<%= paginate @users %>
<div class="info"><%= page_entries_info @users %></div>
ERB
  end

  def index_text
    @users = User.page params[:page]
  end
end

if defined? ActiveRecord
  class AddressesController < ApplicationController
    def index
      @addresses = User::Address.page params[:page]
      render inline: <<-ERB
  <%= @addresses.map(&:street).join("\n") %>
  <%= paginate @addresses %>
  ERB
    end
  end
end

# helpers
Object.const_set(:ApplicationHelper, Module.new)
