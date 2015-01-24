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

        class << self
          def inherited_with_kaminari(kls)
            inherited_without_kaminari(kls)
            kls.send(:include, Kaminari::MongoidExtension::Document.dup)
          end
          alias_method_chain :inherited, :kaminari
        end unless respond_to?(:inherited_with_kaminari)
      end
    end
  end
end
