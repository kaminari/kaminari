class User < ActiveRecord::Base
  default_scope order('name')
end
