require 'kaminari/models/mongoid_criteria_methods'

module Kaminari
  module MongoidExtension
    module Criteria
      extend ActiveSupport::Concern

      included do
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{Kaminari.config.page_method_name}(*args)
            super(*args).criteria.merge(self)
          end
        RUBY
      end
    end

    module Document
      extend ActiveSupport::Concern
      include Kaminari::ConfigurationMethods

      included do
        self.send(:extend, ClassMethods)
        # Fetch the values at the specified page number
        #   Model.page(5)
        scope Kaminari.config.page_method_name, Proc.new {|num|
          limit(default_per_page).offset(calculate_offset(num))
        } do
          include Kaminari::MongoidCriteriaMethods
          include Kaminari::PageScopeMethods
        end
      end

      module ClassMethods
        def calculate_offset(num)
          num = default_per_page * ([num.to_i, 1].max - 1)
          goto_page = Kaminari.config.out_of_range

          return 0 if goto_page == :first && out_of_range?(num)
          return scoped.count - default_per_page if goto_page == :last && out_of_range?(num)
          num
        end

        def out_of_range?(num)
          num + 1 > scoped.count
        end
      end

    end
  end
end
