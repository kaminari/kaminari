require File.join(File.dirname(__FILE__), 'plucky_criteria_methods')

module Kaminari
  module MongoMapperExtension
    module Document
      extend ActiveSupport::Concern
      include Kaminari::ConfigurationMethods

      included do
        # Fetch the values at the specified page number
        #   Model.page(5)
        scope :page, Proc.new {|num|
          limit(default_per_page).offset(default_per_page * ([num.to_i, 1].max - 1))
        }
      end
    end
  end
end