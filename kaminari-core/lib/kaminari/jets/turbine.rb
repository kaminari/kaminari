# frozen_string_literal: true

module Kaminari
  class Turbine < ::Jets::Turbine #:nodoc:
    # Doesn't actually do anything. Just keeping this hook point, mainly for compatibility
    initializer 'kaminari' do
    end
  end
end
