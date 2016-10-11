module Kaminari
end

# load Rails/Railtie
begin
  require 'rails'
rescue LoadError
  #do nothing
end

# load Kaminari components
require 'kaminari/config'
require 'kaminari/exceptions'
require 'kaminari/helpers/paginator'
require 'kaminari/models/page_scope_methods'
require 'kaminari/models/configuration_methods'
require 'kaminari/hooks'

# if not using Railtie, call `Kaminari::Hooks.init` directly
if defined? ::Rails::Railtie
  require 'kaminari/railtie'
  require 'kaminari/engine'
end
