module Kaminari
  # = Helpers
  module ActionViewExtension
    extend ::ActiveSupport::Concern
    module InstanceMethods
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

      # A simple "Twitter like" pagination link that creates a link to the next page.
      #
      # ==== Examples
      # Basic usage:
      #
      #   <%= link_to_next_page @items, 'Next Page' %>
      #
      # Ajax:
      #
      #   <%= link_to_next_page @items, 'Next Page', :remote => true %>
      #
      # By default, it renders nothing if there are no more results on the next page.
      # You can customize this output by passing a block.
      #
      #   <%= link_to_next_page @users, 'Next Page' do %>
      #     <span>No More Pages</span>
      #   <% end %>
      def link_to_next_page(scope, name, options = {}, &block)
        params = options.delete(:params) || {}
        param_name = options.delete(:param_name) || Kaminari.config.param_name
        link_to_unless scope.last_page?, name, params.merge(param_name => (scope.current_page + 1)), options.merge(:rel => 'next') do
          block.call if block
        end
      end
    end
  end
end
