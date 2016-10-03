require 'action_view'
require 'action_view/log_subscriber'
require 'action_view/context'

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
    def paginate(scope, options = {})
      paginator = Kaminari::Helpers::Paginator.new(self, options.reverse_merge(:current_page => scope.current_page, :total_pages => scope.total_pages, :per_page => scope.limit_value, :remote => false))
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
      prev_page = Kaminari::Helpers::PrevPage.new self, options.reverse_merge(:current_page => scope.current_page)

      link_to_if scope.prev_page.present?, name, prev_page.url, options.except(:params, :param_name).reverse_merge(:rel => 'prev') do
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
    #   <%= link_to_next_page @items, 'Next Page', :remote => true %>
    #
    # By default, it renders nothing if there are no more results on the next page.
    # You can customize this output by passing a block.
    #
    #   <%= link_to_next_page @users, 'Next Page' do %>
    #     <span>No More Pages</span>
    #   <% end %>
    def link_to_next_page(scope, name, options = {}, &block)
      next_page = Kaminari::Helpers::NextPage.new self, options.reverse_merge(:current_page => scope.current_page)

      link_to_if scope.next_page.present?, name, next_page.url, options.except(:params, :param_name).reverse_merge(:rel => 'next') do
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
    #   <%= page_entries_info @posts, :entry_name => 'item' %>
    #   #-> Displaying items 6 - 10 of 26 in total
    #
    # It is possible to customize locale for inflection,
    # Override this with the <tt>:entry_locale</tt> parameter,
    # the default value is <tt>I18n.locale</tt>:
    #
    #   <%= page_entries_info @posts, :entry_locale => :'zh-TW' %>
    #   #-> Displaying 文章 6 - 10 of 26 in total
    def page_entries_info(collection, options = {})
      entry_name = options[:entry_name] || collection.entry_name
      entry_locale = options[:entry_locale] || I18n.locale
      if ActiveSupport::VERSION::STRING >= '4.0.0'
        entry_name = entry_name.pluralize(collection.total_count, entry_locale)
      else
        entry_name = entry_name.pluralize unless collection.total_count == 1
      end

      if collection.total_pages < 2
        t('helpers.page_entries_info.one_page.display_entries', :entry_name => entry_name, :count => collection.total_count)
      else
        first = collection.offset_value + 1
        last = (sum = collection.offset_value + collection.limit_value) > collection.total_count ? collection.total_count : sum
        t('helpers.page_entries_info.more_pages.display_entries', :entry_name => entry_name, :first => first, :last => last, :total => collection.total_count)
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
      next_page = Kaminari::Helpers::NextPage.new self, options.reverse_merge(:current_page => scope.current_page)
      prev_page = Kaminari::Helpers::PrevPage.new self, options.reverse_merge(:current_page => scope.current_page)

      output = String.new
      output << tag(:link, :rel => "next", :href => next_page.url) if scope.next_page.present?
      output << tag(:link, :rel => "prev", :href => prev_page.url) if scope.prev_page.present?
      output.html_safe
    end

    module PaginatorExtension
      extend ActiveSupport::Concern

      # so that this instance can actually "render"
      include ::ActionView::Context

      included do
        undef :to_s
        # Redefining to_s not to log each render_partial
        def to_s #:nodoc:
          subscriber = ActionView::LogSubscriber.log_subscribers.detect {|ls| ls.is_a? ActionView::LogSubscriber}

          # There is a logging subscriber
          # and we don't want it to log render_partial
          # It is threadsafe, but might not repress logging
          # consistently in a high-load environment
          if subscriber
            unless defined? subscriber.render_partial_with_logging
              class << subscriber
                alias_method :render_partial_with_logging, :render_partial
                attr_accessor :render_without_logging
                # ugly hack to make a renderer where
                # we can turn logging on or off
                def render_partial(event)
                  render_partial_with_logging(event) unless render_without_logging
                end
              end
            end

            subscriber.render_without_logging = true
            ret = super @window_options.merge :paginator => self
            subscriber.render_without_logging = false

            ret
          else
            super @window_options.merge :paginator => self
          end
        end
      end
    end
    ::Kaminari::Helpers::Paginator.send :include, PaginatorExtension
  end
end
