require 'kaminari/models/data_mapper_collection_methods'

module Kaminari
  module DataMapperExtension
    module Collection
      extend ActiveSupport::Concern
      included do
        include Kaminari::ConfigurationMethods::ClassMethods
        include Kaminari::DataMapperCollectionMethods
        include Kaminari::PageScopeMethods

        # Fetch the values at the specified page number
        #   Model.all(:some => :conditions).page(5)
        def page(num)
          limit(default_per_page).offset(default_per_page * ([num.to_i, 1].max - 1))
        end
      end
    end

    module Model
      extend ActiveSupport::Concern
      included do
        # Fetch the values at the specified page number
        #   Model.page(5)
        def page(*args)
          all.page(*args)
        end

        def per(*args)
          all.per(*args)
        end

        def limit(val)
          all(:limit => val)
        end

        def offset(val)
          all(:offset => val)
        end
      end
    end
  end
end
