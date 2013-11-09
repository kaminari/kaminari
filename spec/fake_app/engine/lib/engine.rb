module Engine
  class Engine < ::Rails::Engine
    isolate_namespace ::Engine
  end
end

Engine::Engine.routes.draw do
  resources :users
end

# controllers
class Engine::UsersController < ::ApplicationController
  def index
    @users = User.page(params[:page]).per(3)
    render :inline => <<-ERB
<%= @users.map(&:name).join("\n") %>
<%= paginate @users %>
ERB
  end
end

# not isolated engine
# for routes mounting test
module TheEngine
  class Engine < Rails::Engine; end
end

TheEngine::Engine.routes.draw do
  resources :articles
end