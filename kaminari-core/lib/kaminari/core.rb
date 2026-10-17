# frozen_string_literal: true

module Kaminari
  # The largest offset that a database column or Array#[] can represent. Beyond this both
  # raise rather than return nothing, and a `?page=` query parameter can easily exceed it.
  MAX_OFFSET = (2**63) - 1

  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new("2.0", "kaminari-core")
  end
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
require 'kaminari/helpers/helper_methods'
require 'kaminari/models/page_scope_methods'
require 'kaminari/models/configuration_methods'
require 'kaminari/models/array_extension'

if defined? ::Rails::Railtie
  require 'kaminari/railtie'
  require 'kaminari/engine'
end
