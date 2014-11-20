class User
  include NoBrainer::Document
  include NoBrainer::Document::DynamicAttributes

  field :name, :type => String
  field :age, :type => Integer

  has_many :projects
end

class User::Address
  include NoBrainer::Document
end

class Project
  include NoBrainer::Document

  field :name, :type => String, :required => true
  belongs_to :user, :required => true
end

