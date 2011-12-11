begin
  require 'sinatra/base'
rescue LoadError
  raise LoadError, 'couldn\'t load `sinatra/base\', check out if appropriately bundled sinatra gem?'
end

require 'kaminari'
module Kaminari
  module Helpers
    autoload :SinatraHelpers, 'kaminari/helpers/sinatra_helpers'
  end
end
Kaminari::Hooks.init!

