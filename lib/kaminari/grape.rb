begin
  require 'grape'
rescue LoadError
  raise LoadError, "couldn't load `grape`, check out if appropriately bundled grape gem?"
end

require 'kaminari'

Kaminari::Hooks.init!

