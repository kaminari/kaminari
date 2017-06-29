# frozen_string_literal: true
module Kaminari
  module FakeGem
    def self.included(base)
      def base.inherited(kls)
        super
        def kls.fake_gem_defined_method; end
      end
    end
  end
end

ActiveSupport.on_load :active_record do
  ActiveRecord::Base.send :include, Kaminari::FakeGem

  # Simulate a gem providing a subclass of ActiveRecord::Base before the Railtie is loaded.
  class GemDefinedModel < ActiveRecord::Base
  end
end
