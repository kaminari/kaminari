require 'kaminari/models/active_record_model_extension'

module Kaminari
  module ActiveRecordExtension
    extend ActiveSupport::Concern
    included do
      @_subclasses_loaded = false
      # Future subclasses will pick up the model extension
      class << self
        def inherited_with_kaminari(kls) #:nodoc:
          # First model should also force subclasses to pick up the model extension as well
          unless @_subclasses_loaded
            self.descendants.each do |kls|
              kls.send(:include, Kaminari::ActiveRecordModelExtension) if kls.superclass == ActiveRecord::Base
            end
            @_subclasses_loaded = true
          end
          inherited_without_kaminari kls
          kls.send(:include, Kaminari::ActiveRecordModelExtension) if kls.superclass == ActiveRecord::Base
        end
        alias_method_chain :inherited, :kaminari
      end
    end
  end
end
