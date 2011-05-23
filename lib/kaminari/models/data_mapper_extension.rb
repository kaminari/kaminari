
module Kaminari
  module DataMapperExtension
    
    #
    module PageScopeMethods
      include ::Kaminari::PageScopeMethods::InstanceMethods
      
      # Specify the <tt>per_page</tt> value for the preceding <tt>page</tt> scope
      #   Model.page(3).per(10)
      def per(num)
        num = num.to_i
        if num <= 0
          self
        else
          #col = model.all(query.options.except(:limit,:offset).merge(:limit => num, :offset => offset_value / limit_value * num))
          col = model.all(query.options.merge(:limit => num, :offset => offset_value / limit_value * num))
          col.send :extend, PageScopeMethods
          col
        end
      end
      
      def limit_value
        query.limit
      end
      
      def offset_value
        query.offset
      end
      
      def total_count
        model.count(query.options.except(:limit,:offset,:order))
      end
      
      def all(options={})
        col = super(options)
        col.send :extend, PageScopeMethods
        col
      end
    end
    
    #
    module Paginatable
	  def page(num)
	    num = [num.to_i, 1].max - 1
        collection = all(:limit => default_per_page, :offset => default_per_page * num)
        collection.send :extend, PageScopeMethods
        collection
      end
    end
    
    
    # This should be included into DataMapper::Collection.
    # MyModel.all.class #=> DataMapper::Collection
    module CollectionInstanceMethods
      include Paginatable
      
      #def default_per_page
      #  model.default_per_page
      #end
    end
    
    # This should be included into DataMapper::Model so that one can call:
    # MyModel.page #=> DataMapper::Collection
    module ModelClassMethods
      include Paginatable
      include Kaminari::ConfigurationMethods::ClassMethods
    end
    
  end
end
