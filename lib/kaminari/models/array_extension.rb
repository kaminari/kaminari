module Kaminari
  # Kind of Array that can paginate
  class PaginatableArray < Array
    include Kaminari::ConfigurationMethods::ClassMethods

    attr_internal_accessor :limit_value, :offset_value

    def initialize(original_array, limit_val = default_per_page, offset_val = 0) #:nodoc:
      @_original_array, @_limit_value, @_offset_value = original_array, limit_val, offset_val
      super(original_array[offset_val, limit_val] || [])
    end

    # items at the specified "page"
    def page(num = 1)
      offset(limit_value * ([num.to_i, 1].max - 1))
    end

    # returns another chunk of the original array
    def limit(num)
      self.class.new @_original_array, num, offset_value
    end

    # total item numbers of the original array
    def total_count
      @_original_array.count
    end

    # returns another chunk of the original array
    def offset(num)
      arr = self.class.new @_original_array, limit_value, num
      class << arr
        include Kaminari::PageScopeMethods
      end
      arr
    end
  end

  # Wrap an Array object to make it paginatable
  def self.paginate_array(array)
    PaginatableArray.new array
  end
end
