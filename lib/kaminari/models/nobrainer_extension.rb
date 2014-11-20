require 'kaminari/models/nobrainer_criteria_methods'

module Kaminari
  module NoBrainerExtension
    module Document
      extend ActiveSupport::Concern
      include Kaminari::ConfigurationMethods

      included do
        # Fetch the values at the specified page number
        #   Model.page(5)
        scope Kaminari.config.page_method_name do |num|
          limit(default_per_page)
            .skip(default_per_page * ([num.to_i, 1].max - 1))
            .extend(Kaminari::NoBrainerCriteriaMethods)
        end
      end
    end
  end
end
