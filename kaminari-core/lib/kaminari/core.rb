module Kaminari
end

# load Rails/Railtie
begin
  require 'rails'
rescue LoadError
  #do nothing
end

$stderr.puts <<-EOC if !defined?(::Rails::Railtie) && !defined?(Sinatra) && !defined?(Grape)
warning: no framework detected.

Your Gemfile might not be configured properly.
---- e.g. ----
Rails:
    gem 'kaminari'

Sinatra/Padrino:
    gem 'kaminari-sinatra'

Grape:
    gem 'kaminari-grape'

EOC

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
