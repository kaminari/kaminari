require 'kaminari/models/active_record_model_extension'

module Kaminari
  module ActiveRecordExtension
    extend ActiveSupport::Concern

    module ClassMethods
      # Future subclasses will pick up the model extension
      def inherited(kls) #:nodoc:
        super
        kls.send(:include, Kaminari::ActiveRecordModelExtension) if kls.superclass == ::ActiveRecord::Base
      end
    end

    included do
      # Existing subclasses pick up the model extension as well
      self.descendants.each do |kls|
        kls.send(:include, Kaminari::ActiveRecordModelExtension) if kls.superclass == ::ActiveRecord::Base
      end
    end
  end
end
