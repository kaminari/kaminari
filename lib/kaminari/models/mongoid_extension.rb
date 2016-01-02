require 'kaminari/models/mongoid_criteria_methods'

module Kaminari
  module MongoidExtension
    module Document
      extend ActiveSupport::Concern
      include Kaminari::ConfigurationMethods

      included do
        scope Kaminari.config.page_method_name, Proc.new {|num|
          limit(default_per_page).offset(default_per_page * ((num = num.to_i - 1) < 0 ? 0 : num))
        } do
          include Kaminari::MongoidCriteriaMethods
          include Kaminari::PageScopeMethods
        end
      end

      module ClassMethods
        def inherited(kls)
          super
          kls.send(:include, Kaminari::MongoidExtension::Document.dup)
        end
      end if Mongoid::VERSION < '5.0.0'
    end
  end
end
