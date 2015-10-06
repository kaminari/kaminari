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
      options[:total_pages] ||= options[:num_pages] || scope.total_pages

      paginator = Kaminari::Helpers::Paginator.new(self, options.reverse_merge(current_page: scope.current_page, per_page: scope.limit_value, remote: false))
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
    #   <%= link_to_previous_page @items, 'Previous Page', remote: true %>
    #
    # By default, it renders nothing if there are no more results on the previous page.
    # You can customize this output by passing a block.
    #
    #   <%= link_to_previous_page @users, 'Previous Page' do %>
    #     <span>At the Beginning</span>
    #   <% end %>
    def link_to_previous_page(scope, name, options = {}, &block)
      prev_page = Kaminari::Helpers::PrevPage.new self, options.reverse_merge(current_page: scope.current_page)

      link_to_if scope.prev_page.present?, name, prev_page.url, options.except(:params, :param_name).reverse_merge(rel: 'prev') do
        block.call if block
      end
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
    #   <%= link_to_next_page @items, 'Next Page', remote: true %>
    #
    # By default, it renders nothing if there are no more results on the next page.
    # You can customize this output by passing a block.
    #
    #   <%= link_to_next_page @users, 'Next Page' do %>
    #     <span>No More Pages</span>
    #   <% end %>
    def link_to_next_page(scope, name, options = {}, &block)
      next_page = Kaminari::Helpers::NextPage.new self, options.reverse_merge(current_page: scope.current_page)

      link_to_if scope.next_page.present?, name, next_page.url, options.except(:params, :param_name).reverse_merge(rel: 'next') do
        block.call if block
      end
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
    #   <%= page_entries_info @posts, entry_name: 'item' %>
    #   #-> Displaying items 6 - 10 of 26 in total
    def page_entries_info(collection, options = {})
      entry_name = options[:entry_name] || collection.entry_name
      entry_name = entry_name.pluralize unless collection.total_count == 1

      if collection.total_pages < 2
        t('helpers.page_entries_info.one_page.display_entries', entry_name: entry_name, count: collection.total_count)
      else
        first = collection.offset_value + 1
        last = collection.last_page? ? collection.total_count : collection.offset_value + collection.limit_value
        t('helpers.page_entries_info.more_pages.display_entries', entry_name: entry_name, first: first, last: last, total: collection.total_count)
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
      next_page = Kaminari::Helpers::NextPage.new self, options.reverse_merge(current_page: scope.current_page)
      prev_page = Kaminari::Helpers::PrevPage.new self, options.reverse_merge(current_page: scope.current_page)

      output = ""
      output << tag(:link, rel: "next", href: next_page.url) if scope.next_page.present?
      output << tag(:link, rel: "prev", href: prev_page.url) if scope.prev_page.present?
      output.html_safe
    end
  end
end
