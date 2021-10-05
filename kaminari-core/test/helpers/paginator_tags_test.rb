# frozen_string_literal: true

require 'test_helper'

if defined? ::Kaminari::Actionview
  class PaginatorTagsTest < ActionView::TestCase
    # A test paginator that can detect instantiated tags inside
    class TagSpy < Kaminari::Helpers::Paginator
      def initialize(*, **)
        super
        @tags = []
      end

      def page_tag(page)
        @tags << page.to_i
        super
      end

      %w[first_page prev_page next_page last_page gap].each do |tag|
        eval <<-DEF, nil, __FILE__, __LINE__ + 1
          def #{tag}_tag
            @tags << :#{tag}
            super
          end
        DEF
      end

      def partial_path
        'kaminari/paginator'
      end

      def to_s
        super
        @tags
      end
    end

    def tags_for(collection, window: 4, outer_window: 0)
      view.paginate(collection, paginator_class: TagSpy, window: window, outer_window: outer_window, params: {controller: 'users', action: 'index'})
    end

    teardown do
      User.delete_all
    end

    test '1 page in total' do
      3.times {|i| User.create! name: "user#{i}"}
      assert_empty tags_for(User.page(1).per(3))
    end

    sub_test_case 'when having 1 outer_window (and 1 inner window)' do
      def tags_for(collection, window: 1, outer_window: 1)
        super
      end

      test '10 pages in total' do
        20.times {|i| User.create! name: "user#{i}"}

        assert_equal [1, 2, :gap, 10, :next_page, :last_page], tags_for(User.page(1).per(2))
        assert_equal [:first_page, :prev_page, 1, 2, 3, :gap, 10, :next_page, :last_page], tags_for(User.page(2).per(2))
        assert_equal [:first_page, :prev_page, 1, 2, 3, 4, :gap, 10, :next_page, :last_page], tags_for(User.page(3).per(2))
        # the 3rd page doesn't become a gap because it's a single gap
        assert_equal [:first_page, :prev_page, 1, 2, 3, 4, 5, :gap, 10, :next_page, :last_page], tags_for(User.page(4).per(2))
        assert_equal [:first_page, :prev_page, 1, :gap, 4, 5, 6, :gap, 10, :next_page, :last_page], tags_for(User.page(5).per(2))
        assert_equal [:first_page, :prev_page, 1, :gap, 5, 6, 7, :gap, 10, :next_page, :last_page], tags_for(User.page(6).per(2))
        # the 9th page doesn't become a gap because it's a single gap
        assert_equal [:first_page, :prev_page, 1, :gap, 6, 7, 8, 9, 10, :next_page, :last_page], tags_for(User.page(7).per(2))
        assert_equal [:first_page, :prev_page, 1, :gap, 7, 8, 9, 10, :next_page, :last_page], tags_for(User.page(8).per(2))
        assert_equal [:first_page, :prev_page, 1, :gap, 8, 9, 10, :next_page, :last_page], tags_for(User.page(9).per(2))
        assert_equal [:first_page, :prev_page, 1, :gap, 9, 10], tags_for(User.page(10).per(2))
      end
    end
  end
end
