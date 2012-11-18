require 'kaminari/models/plucky_criteria_methods'
require 'kaminari/models/page_extensions'

module Kaminari
  module MongoMapperExtension
    module Document
      extend ActiveSupport::Concern
      include Kaminari::ConfigurationMethods

      included do
        self.send(:extend, Kaminari::PageExtensions)
        # Fetch the values at the specified page number
        #   Model.page(5)
        scope Kaminari.config.page_method_name, Proc.new {|num|
          limit(default_per_page).offset(calculate_offset(num))
        }
      end
    end

  end
end
