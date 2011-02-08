require 'active_record'
require 'action_controller/railtie'
require 'action_view/railtie'

ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection('test')

app = Class.new(Rails::Application)
app.config.secret_token = "3b7cd727ee24e8444053437c36cc66c4"
app.config.session_store :cookie_store, :key => "_myapp_session"
app.config.active_support.deprecation = :log
app.initialize!

app.routes.draw do
  resources :users
end

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

Object.const_set(:ApplicationHelper, Module.new)
