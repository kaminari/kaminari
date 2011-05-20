# Simulate a gem providing a subclass of ActiveRecord::Base before the Railtie is loaded.

require 'active_record'

class GemDefinedModel < ActiveRecord::Base
end
