module Kaminari
  module ActionViewExtension
    extend ActiveSupport::Concern
    module InstanceMethods
      # = Helpers
      #
      # A helper that renders the pagination links.
      #
      #   <%= paginate @articles %>
      #
      # ==== Options
      # * <tt>:window</tt> - The "inner window" size (4 by default).
      # * <tt>:outer_window</tt> - The "outer window" size (0 by default).
      # * <tt>:left</tt> - The "left outer window" size (0 by default).
      # * <tt>:right</tt> - The "right outer window" size (0 by default).
      # * <tt>:params</tt> - url_for parameters for the links (:controller, :action, etc.)
      # * <tt>:param_name</tt> - parameter name for page number in the links (:page by default)
      # * <tt>:remote</tt> - Ajax? (false by default)
      # * <tt>:ANY_OTHER_VALUES</tt> - Any other hash key & values would be directly passed into each tag as :locals value.
      def paginate(scope, options = {}, &block)
        paginator = Kaminari::Helpers::Paginator.new self, options.reverse_merge(:current_page => scope.current_page, :num_pages => scope.num_pages, :per_page => scope.limit_value, :param_name => Kaminari.config.param_name, :remote => false)
        paginator.to_s
      end
    end
  end
end
