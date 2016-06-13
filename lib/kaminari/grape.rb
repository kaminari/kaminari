require 'grape'
require 'kaminari'

ActiveSupport::Deprecation.warn 'Kaminari Grape support has been extracted to a separate gem, and will be removed in the next 1.0 release. Please bundle kaminari-grape gem.'

Kaminari::Hooks.init
