module Kaminari
  class Hooks
    def self.init
      require 'kaminari/models/array_extension'
    end
  end
end
