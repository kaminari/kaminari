require 'active_record'
require 'action_controller/railtie'
require 'action_view/railtie'

# database
ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection('test')

# config
app = Class.new(Rails::Application)
app.config.secret_token = "3b7cd727ee24e8444053437c36cc66c4"
app.config.session_store :cookie_store, :key => "_myapp_session"
app.config.active_support.deprecation = :log
app.initialize!

# routes
app.routes.draw do
  resources :users
end

# models
class User < ActiveRecord::Base
  has_many :authorships
  has_many :readerships
  has_many :books_authored, :through => :authorships, :source => :book
  has_many :books_read, :through => :readerships, :source => :book

  def readers
    User.joins(:books_read => :authors).where(:authors_books => {:id => self})
  end

  scope :by_name, order(:name)
  scope :by_read_count, lambda {
    cols = if connection.adapter_name == "PostgreSQL"
      column_names.map { |column| %{"users"."#{column}"} }.join(", ")
    else
      '"users"."id"'
    end
    group(cols).select("count(readerships.id) AS read_count, #{cols}").order('read_count DESC')
  }
end
class Authorship < ActiveRecord::Base
  belongs_to :user
  belongs_to :book
end
class Readership < ActiveRecord::Base
  belongs_to :user
  belongs_to :book
end
class Book < ActiveRecord::Base
  has_many :authorships
  has_many :readerships
  has_many :authors, :through => :authorships, :source => :user
  has_many :readers, :through => :readerships, :source => :user
end
# a model that is a descendant of AR::Base but doesn't directly inherit AR::Base
class Admin < User
end

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

# helpers
Object.const_set(:ApplicationHelper, Module.new)

#migrations
class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table(:gem_defined_models) { |t| t.string :name; t.integer :age }
    create_table(:users) {|t| t.string :name; t.integer :age}
    create_table(:books) {|t| t.string :title}
    create_table(:readerships) {|t| t.integer :user_id; t.integer :book_id }
    create_table(:authorships) {|t| t.integer :user_id; t.integer :book_id }
  end
end
