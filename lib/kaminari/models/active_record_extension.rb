require 'kaminari/models/active_record_relation_methods'

module Kaminari
  module ActiveRecordExtension
    extend ActiveSupport::Concern
    included do
      def self.inherited(kls) #:nodoc:
        super

        kls.class_eval do
          include Kaminari::ConfigurationMethods

          # Fetch the values at the specified page number
          #   Model.page(5)
          scope :page, Proc.new {|num|
            limit(default_per_page).offset(default_per_page * ([num.to_i, 1].max - 1))
          } do
            include Kaminari::ActiveRecordRelationMethods
            include Kaminari::PageScopeMethods
          end
        end if kls.superclass == ActiveRecord::Base
      end
    end
  end
end
