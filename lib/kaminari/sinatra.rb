require 'kaminari'
module Kaminari
  module Helpers
    autoload :SinatraHelpers, 'kaminari/helpers/sinatra_helpers'
  end
end
Kaminari::Hooks.init!

