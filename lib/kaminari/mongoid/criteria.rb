module Kaminari
  module Mongoid
    module Criteria
      extend ActiveSupport::Concern

      included do
        delegate :page, :per, :num_pages, :current_page, :limit_value, :to => '@klass'
      end
    end
  end
end
