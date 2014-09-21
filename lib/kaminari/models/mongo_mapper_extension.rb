require 'kaminari/models/plucky_criteria_methods'

module Kaminari
  module MongoMapperExtension
    module Document
      extend ActiveSupport::Concern
      include Kaminari::ConfigurationMethods

      included do
        # Fetch the values at the specified page number
        #   Model.page(5)
        scope Kaminari.config.page_method_name, Proc.new {|num|
          limit(default_per_page).offset(default_per_page * ([(num.class.public_method_defined?(:to_i) ? num.to_i : 0), 1].max - 1))
        }
      end
    end
  end
end
