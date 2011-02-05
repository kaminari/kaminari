module Kaminari
  module ActiveRecord
    extend ActiveSupport::Concern
    PER_PAGE = 10

    included do
      def self.inherited(kls)
        kls.class_eval do
          # page(5)
          scope :page, lambda {|num|
            offset(PER_PAGE * ([num.to_i, 1].max - 1)).limit(PER_PAGE)
          } do
            # page(3).per(20)
            def per(num)
              offset(offset_value / limit_value * num).limit(num)
            end

            def num_pages
              (except(:offset, :limit).count.to_f / limit_value).ceil
            end

            def current_page
              (offset_value / limit_value) + 1
            end
          end
        end
      end
    end
  end
end
