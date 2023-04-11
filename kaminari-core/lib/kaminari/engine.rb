# frozen_string_literal: true

module Kaminari #:nodoc:
  class Engine < ::Rails::Engine #:nodoc:
    initializer :deprecator do |app|
      app.deprecators[:kaminari] = Kaminari.deprecator if app.respond_to?(:deprecators)
    end
  end
end
