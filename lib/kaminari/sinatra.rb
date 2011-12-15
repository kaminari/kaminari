begin
  require 'sinatra/base'
rescue LoadError
  raise LoadError, "couldn't load `sinatra/base`, check out if appropriately bundled sinatra gem?"
end

require 'kaminari'
module Kaminari::Helpers
end
require 'kaminari/helpers/sinatra_helpers'

Kaminari::Hooks.init!

