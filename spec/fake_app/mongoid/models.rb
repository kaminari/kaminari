class User
  include ::Mongoid::Document
  if Mongoid::VERSION >= '4.0.0'
    include Mongoid::Attributes::Dynamic
  end

  field :name, :type => String
  field :age, :type => Integer
end

class User::Address
  include ::Mongoid::Document
end

class Product
  include ::Mongoid::Document
end

class Device < Product
  paginates_per 100
end

class Android < Device
  paginates_per 200
end

class MongoMongoidExtensionDeveloper
  include ::Mongoid::Document
  field :salary, :type => Integer
  embeds_many :frameworks
end

class Framework
  include ::Mongoid::Document
  field :name, :type => String
  field :language, :type => String
  embedded_in :mongo_mongoid_extension_developer
end
