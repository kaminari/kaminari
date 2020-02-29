# frozen_string_literal: true

# models
class User < ActiveRecord::Base
  has_many :authorships
  has_many :readerships
  has_many :books_authored, through: :authorships, source: :book
  has_many :books_read, through: :readerships, source: :book
  has_many :addresses, class_name: 'User::Address'

  def readers
    User.joins(books_read: :authors).where(authors_books: {id: self})
  end

  scope :by_name, -> { order(:name) }
  scope :by_read_count, -> {
    cols = if connection.adapter_name == "PostgreSQL"
      column_names.map { |column| %{"users"."#{column}"} }
    else
      ['users.id']
    end
    group(*cols).select("count(readerships.id) AS read_count, #{cols.join(', ')}").order('read_count DESC')
  }
end
class Authorship < ActiveRecord::Base
  belongs_to :user
  belongs_to :book
end
class CurrentAuthorship < ActiveRecord::Base
  self.table_name = 'authorships'
  belongs_to :user
  belongs_to :book
  default_scope -> { where(deleted_at: nil) }
end
class Readership < ActiveRecord::Base
  belongs_to :user
  belongs_to :book
end
class Book < ActiveRecord::Base
  has_many :authorships
  has_many :readerships
  has_many :authors, through: :authorships, source: :user
  has_many :readers, through: :readerships, source: :user
end
# a model that is a descendant of AR::Base but doesn't directly inherit AR::Base
class Admin < User
end
# a model with namespace
class User::Address < ActiveRecord::Base
  belongs_to :user
end
class Animal < ActiveRecord::Base; end
class Mammal < Animal; end
class Dog < Mammal; end
class Cat < Mammal; end
class Insect < Animal; end

# a class that uses abstract class
class Product < ActiveRecord::Base
  self.abstract_class = true
end
class Device < Product
end

# migrations
ActiveRecord::Migration.verbose = false
ActiveRecord::Tasks::DatabaseTasks.root = Dir.pwd
ActiveRecord::Tasks::DatabaseTasks.drop_current 'test'
ActiveRecord::Tasks::DatabaseTasks.create_current 'test'

class CreateAllTables < ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[5.0] : ActiveRecord::Migration
  def self.up
    create_table(:gem_defined_models) { |t| t.string :name; t.integer :age }
    create_table(:users) {|t| t.string :name; t.integer :age}
    create_table(:books) {|t| t.string :title}
    create_table(:readerships) {|t| t.integer :user_id; t.integer :book_id }
    create_table(:authorships) {|t| t.integer :user_id; t.integer :book_id; t.datetime :deleted_at }
    create_table(:user_addresses) {|t| t.string :street; t.integer :user_id }
    create_table(:devices) {|t| t.string :name; t.integer :age}
    create_table(:animals) {|t| t.string :type; t.string :name}
  end
end
CreateAllTables.up
