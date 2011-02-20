require File.join(File.dirname(__FILE__), 'mongoid_criteria_methods')
module Kaminari
  module MongoidExtension
    module Criteria
      extend ActiveSupport::Concern

      included do
        delegate :page, :per, :num_pages, :current_page, :limit_value, :offset_value, :pagination_count, :to => '@klass'
      end
    end

    module Document
      extend ActiveSupport::Concern
      include Kaminari::ConfigurationMethods

      included do
        # Fetch the values at the specified page number
        #   Model.page(5)
        scope :page, Proc.new {|num|
          limit(default_per_page).offset(default_per_page * ([num.to_i, 1].max - 1))
        } do
          include Kaminari::MongoidCriteriaMethods
          include Kaminari::PageScopeMethods
        end
      end
    end
  end
end
