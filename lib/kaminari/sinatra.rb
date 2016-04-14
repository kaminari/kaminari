require 'sinatra/base'
require 'kaminari'
require 'kaminari/helpers/sinatra_helpers'

ActiveSupport::Deprecation.warn 'Kaminari Sinatra support has been extracted to a separate gem, and will be removed in the next 1.0 release. Please bundle kaminari-sinatra gem.'

Kaminari::Hooks.init
