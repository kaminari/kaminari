require 'active_support/core_ext/module'
module Kaminari
  # Kind of Array that can paginate
  class PaginatableArray < Array
    include Kaminari::ConfigurationMethods::ClassMethods

    attr_internal_accessor :limit_value, :offset_value

    # ==== Options
    # * <tt>:limit</tt> - limit
    # * <tt>:offset</tt> - offset
    # * <tt>:total_count</tt> - total_count
    def initialize(original_array = [], options = {})
      @_original_array, @_limit_value, @_offset_value, @_total_count = original_array, (options[:limit] || default_per_page).to_i, options[:offset].to_i, options[:total_count]

      if options[:limit] && options[:offset]
        extend Kaminari::PageScopeMethods
      end

      if options[:total_count]
        super original_array
      else
        super(original_array[@_offset_value, @_limit_value] || [])
      end
    end

    # items at the specified "page"
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{Kaminari.config.page_method_name}(num = 1)
        offset(limit_value * ([num.to_i, 1].max - 1))
      end
    RUBY

    # returns another chunk of the original array
    def limit(num)
      self.class.new @_original_array, :limit => num, :offset => @_offset_value, :total_count => @_total_count
    end

    # total item numbers of the original array
    def total_count
      @_total_count || @_original_array.count
    end

    # returns another chunk of the original array
    def offset(num)
      self.class.new @_original_array, :limit => @_limit_value, :offset => calculate_offset(num), :total_count => @_total_count
    end

    def calculate_offset(num)
      goto_page = Kaminari.config.out_of_range

      return 0 if goto_page == :first && out_of_range?(num)
      return total_count - @_limit_value if goto_page == :last && out_of_range?(num)
      num
    end

    def out_of_range?(num)
      num + 1 > total_count
    end

  end

  # Wrap an Array object to make it paginatable
  # ==== Options
  # * <tt>:limit</tt> - limit
  # * <tt>:offset</tt> - offset
  # * <tt>:total_count</tt> - total_count
  def self.paginate_array(array, options = {})
    PaginatableArray.new array, options
  end
end
