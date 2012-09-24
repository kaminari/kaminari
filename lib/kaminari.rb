module Kaminari
end

# load Rails/Railtie
begin
  require 'rails'
rescue LoadError
  #do nothing
end

$stderr.puts <<-EOC if !defined?(Rails) && !defined?(Sinatra) && !defined?(Grape)
warning: no framework detected.

Your Gemfile might not be configured properly.
---- e.g. ----
Rails:
    gem 'kaminari'

Sinatra/Padrino:
    gem 'kaminari', :require => 'kaminari/sinatra'

Grape:
    gem 'kaminari', :require => 'kaminari/grape'

EOC

# load Kaminari components
require 'kaminari/config'
require 'kaminari/helpers/action_view_extension'
require 'kaminari/helpers/paginator'
require 'kaminari/models/page_scope_methods'
require 'kaminari/models/configuration_methods'
require 'kaminari/hooks'

# if not using Railtie, call `Kaminari::Hooks.init` directly
if defined? Rails
  require 'kaminari/railtie'
  require 'kaminari/engine'
end
