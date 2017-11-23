# frozen_string_literal: true
require 'test_helper'

class NavigationTest < Test::Unit::TestCase
  include Capybara::DSL

  setup do
    1.upto(100) {|i| User.create! name: "user#{'%03d' % i}" }
  end

  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
    User.delete_all
  end

  def go_to_next_page
    within('span.next') { click_link 'Next ›' }
  end

  def go_to_prev_page
    within('span.prev') { click_link '‹ Prev' }
  end

  def go_to_first_page
    within('span.first') { click_link '« First' }
  end

  def go_to_last_page
    within('span.last') { click_link 'Last »' }
  end

  def assert_current_page(page_num)
    within 'span.page.current' do
      assert page.has_content? page_num
    end
  end

  def within_navigation(&block)
    within 'nav.pagination', &block
  end

  test 'navigating by pagination links (with Paginator)' do
    visit '/users'

    assert page.has_no_content? 'previous page'
    assert page.has_content? 'next page'

    within_navigation do
      assert_current_page(1)
      go_to_next_page
    end

    assert page.has_content? 'previous page'
    assert page.has_content? 'next page'

    within_navigation do
      assert_current_page(2)
      go_to_last_page
    end

    assert page.has_content? 'previous page'
    assert page.has_no_content? 'next page'

    within_navigation do
      assert_current_page(4)
      go_to_prev_page
    end

    assert page.has_content? 'previous page'
    assert page.has_content? 'next page'

    within_navigation do
      assert_current_page(3)
      go_to_first_page
    end

    within_navigation do
      assert_current_page(1)
    end

    within 'div.info' do
      assert page.has_text? 'Displaying users 1'
    end
  end

  test 'navigating by pagination links (with WithoutCountPaginator)' do
    visit '/users/index_without_count'

    within_navigation do
      assert_current_page(1)
      go_to_next_page
    end

    within_navigation do
      assert_current_page(2)
      go_to_next_page
    end

    within_navigation do
      assert_current_page(3)
      go_to_prev_page
    end

    within_navigation do
      assert_current_page(2)
      go_to_first_page
    end

    within_navigation do
      assert_current_page(1)
    end
  end
end
