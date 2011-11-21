require 'kaminari'
module Kaminari
  module Helpers
    autoload :SinatraHelper, 'kaminari/helpers/sinatra_helper'
  end
end
Kaminari::Hooks.init!

