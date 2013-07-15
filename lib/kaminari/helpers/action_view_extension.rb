module Kaminari
  # = Helpers
  module ActionViewExtension
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
      paginator = Kaminari::Helpers::Paginator.new self, options.reverse_merge(:current_page => scope.current_page, :total_pages => scope.total_pages, :per_page => scope.limit_value, :param_name => Kaminari.config.param_name, :remote => false)
      paginator.to_s
    end

    # A simple "Twitter like" pagination link that creates a link to the previous page.
    #
    # ==== Examples
    # Basic usage:
    #
    #   <%= link_to_previous_page @items, 'Previous Page' %>
    #
    # Ajax:
    #
    #   <%= link_to_previous_page @items, 'Previous Page', :remote => true %>
    #
    # By default, it renders nothing if there are no more results on the previous page.
    # You can customize this output by passing a block.
    #
    #   <%= link_to_previous_page @users, 'Previous Page' do %>
    #     <span>At the Beginning</span>
    #   <% end %>
    def link_to_previous_page(scope, name, options = {}, &block)
      kaminari_link_to_page(scope, name, scope.first_page?, -1, 'previous', options, &block)
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
      kaminari_link_to_page(scope, name, scope.last_page?, 1, 'next', options, &block)
    end

    # Renders a helpful message with numbers of displayed vs. total entries.
    # Ported from mislav/will_paginate
    #
    # ==== Examples
    # Basic usage:
    #
    #   <%= page_entries_info @posts %>
    #   #-> Displaying posts 6 - 10 of 26 in total
    #
    # By default, the message will use the humanized class name of objects
    # in collection: for instance, "project types" for ProjectType models.
    # The namespace will be cutted out and only the last name will be used.
    # Override this with the <tt>:entry_name</tt> parameter:
    #
    #   <%= page_entries_info @posts, :entry_name => 'item' %>
    #   #-> Displaying items 6 - 10 of 26 in total
    def page_entries_info(collection, options = {})
      if collection.total_pages < 2
        t('helpers.page_entries_info.one_page.display_entries', :entry_name => kaminari_entry_name(collection, options), :count => collection.total_count)
      else
        first = collection.offset_value + 1
        last = collection.last_page? ? collection.total_count : collection.offset_value + collection.limit_value
        t('helpers.page_entries_info.more_pages.display_entries', :entry_name => kaminari_entry_name(collection, options), :first => first, :last => last, :total => collection.total_count)
      end.html_safe
    end

    # Renders rel="next" and rel="prev" links to be used in the head.
    #
    # ==== Examples
    # Basic usage:
    #
    #   In head:
    #   <head>
    #     <title>My Website</title>
    #     <%= yield :head %>
    #   </head>
    #
    #   Somewhere in body:
    #   <% content_for :head do %>
    #     <%= rel_next_prev_link_tags @items %>
    #   <% end %>
    #
    #   #-> <link rel="next" href="/items/page/3" /><link rel="prev" href="/items/page/1" />
    #
    def rel_next_prev_link_tags(scope, options = {})
      params = options.delete(:params) || {}
      param_name = options.delete(:param_name) || Kaminari.config.param_name

      output = ""
      output << '<link rel="next" href="' + url_for(params.merge(param_name => (scope.current_page + 1))) + '"/>' unless scope.last_page?
      output << '<link rel="prev" href="' + url_for(params.merge(param_name => (scope.current_page - 1))) + '"/>' unless scope.first_page?

      output.html_safe
    end

    private
    def kaminari_entry_name(collection, options)
      entry_name = if options[:entry_name]
        options[:entry_name]
      elsif collection.empty? || collection.is_a?(PaginatableArray)
        'entry'
      else
        if collection.respond_to? :model  # DataMapper
          collection.model.model_name.human.downcase
        else  # AR
          collection.model_name.human.downcase
        end
      end
      collection.total_count == 1 ? entry_name : entry_name.pluralize
    end

    def kaminari_link_to_page(scope, name, dont_link, offset, rel, options = {}, &block)
      params = options.delete(:params) || {}
      param_name = options.delete(:param_name) || Kaminari.config.param_name
      link_to_unless dont_link, name, params.merge(param_name => (scope.current_page + offset)), options.reverse_merge(:rel => rel) do
        block.call if block
      end
    end
  end
end
