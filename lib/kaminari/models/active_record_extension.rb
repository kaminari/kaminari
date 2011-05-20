require File.join(File.dirname(__FILE__), 'active_record_model_extension')

module Kaminari
  module ActiveRecordExtension
    extend ActiveSupport::Concern
    included do
      # Future subclasses will pick up the model extension
      def self.inherited(kls) #:nodoc:
        super
        kls.send(:include, Kaminari::ActiveRecordModelExtension)
      end

      # Existing subclasses pick up the model extension as well
      self.descendants.each do |kls|
        kls.send(:include, Kaminari::ActiveRecordModelExtension)
      end
    end
  end
end
