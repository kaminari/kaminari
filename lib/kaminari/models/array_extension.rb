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
      @_original_array, @_limit_value, @_offset_value, @_total_count, @_padding = original_array, (options[:limit] || default_per_page).to_i, options[:offset].to_i, options[:total_count], options[:padding].to_i

      if options[:limit] && options[:offset]
        extend Kaminari::PageScopeMethods
      end

      if @_total_count.present? && @_total_count <= original_array.count
        original_array = original_array.first(@_total_count)[@_offset_value, @_limit_value]
      end

      if @_total_count.nil?
        original_array = original_array[@_offset_value, @_limit_value]
      end

      super(original_array || [])
    end

    def entry_name
      "entry"
    end

    # items at the specified "page"
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{Kaminari.config.page_method_name}(num = 1)
        offset(limit_value * ((num = num.to_i - 1) < 0 ? 0 : num))
      end
    RUBY

    # returns another chunk of the original array
    def limit(num)
      self.class.new @_original_array, :limit => num, :offset => @_offset_value, :total_count => @_total_count, :padding => @_padding
    end

    # total item numbers of the original array
    def total_count
      @_total_count || @_original_array.count
    end

    # returns another chunk of the original array
    def offset(num)
      self.class.new @_original_array, :limit => @_limit_value, :offset => num, :total_count => @_total_count, :padding => @_padding
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
