# frozen_string_literal: true

require 'test_helper'

class PaginatableArrayTest < ActiveSupport::TestCase
  setup do
    @array = Kaminari::PaginatableArray.new((1..100).to_a)
  end

  test 'initial state' do
    assert_equal 0, Kaminari::PaginatableArray.new.count
  end

  test 'specifying limit and offset when initializing' do
    assert_equal 3, Kaminari::PaginatableArray.new((1..100).to_a, limit: 10, offset: 20).current_page
  end

  sub_test_case '#page' do
    def assert_first_page_of_array(arr)
      assert_equal 25, arr.count
      assert_equal 1, arr.current_page
      assert_equal 1, arr.first
    end

    def assert_blank_array_page(arr)
      assert_equal 0, arr.count
    end

    test 'page 1' do
      assert_first_page_of_array @array.page(1)
    end

    test 'page 2' do
      arr = @array.page 2

      assert_equal 25, arr.count
      assert_equal 2, arr.current_page
      assert_equal 26, arr.first
    end

    test 'page without an argument' do
      assert_first_page_of_array @array.page
    end

    test 'page < 1' do
      assert_first_page_of_array @array.page(0)
    end

    test 'page > max page' do
      assert_blank_array_page @array.page(5)
    end
  end

  sub_test_case '#per' do
    test 'page 1 per 5' do
      arr = @array.page(1).per(5)

      assert_equal 5, arr.count
      assert_equal 1, arr.first
    end

    test 'page 1 per 0' do
      assert_equal 0, @array.page(1).per(0).count
    end
  end

  sub_test_case '#padding' do
    test 'page 1 per 5 padding 1' do
      arr = @array.page(1).per(5).padding(1)

      assert_equal 5, arr.count
      assert_equal 2, arr.first
    end

    test 'page 1 per 5 padding "1" (as string)' do
      arr = @array.page(1).per(5).padding('1')

      assert_equal 5, arr.count
      assert_equal 2, arr.first
    end

    test 'page 19 per 5 padding 5' do
      arr = @array.page(19).per(5).padding(5)

      assert_equal 19, arr.current_page
      assert_equal 19, arr.total_pages
    end

    test 'per 25, padding 25' do
      assert_equal 3, @array.page(1).padding(25).total_pages
    end

    test 'Negative padding' do
      assert_raise(ArgumentError) { @array.page(1).per(5).padding(-1) }
    end
  end

  sub_test_case '#total_pages' do
    test 'per 25 (default)' do
      assert_equal 4, @array.page.total_pages
    end

    test 'per 7' do
      assert_equal 15, @array.page(2).per(7).total_pages
    end

    test 'per 65536' do
      assert_equal 1, @array.page(50).per(65536).total_pages
    end

    test 'per 0' do
      assert_raise(Kaminari::ZeroPerPageOperation) { @array.page(50).per(0).total_pages }
    end

    test 'per -1 (using default)' do
      assert_equal 4, @array.page(5).per(-1).total_pages
    end

    test 'per "String value that can not be converted into Number" (using default)' do
      assert_equal 4, @array.page(5).per('aho').total_pages
    end
  end

  sub_test_case '#current_page' do
    test 'any page, per 0' do
      assert_raise(Kaminari::ZeroPerPageOperation) { @array.page.per(0).current_page }
    end

    test 'page 1' do
      assert_equal 1, @array.page(1).current_page
    end

    test 'page 2' do
      assert_equal 2, @array.page(2).per(3).current_page
    end
  end

  sub_test_case '#next_page' do
    test 'page 1' do
      assert_equal 2, @array.page.next_page
    end

    test 'page 5' do
      assert_nil @array.page(5).next_page
    end
  end

  sub_test_case '#prev_page' do
    test 'page 1' do
      assert_nil @array.page.prev_page
    end

    test 'page 3' do
      assert_equal 2, @array.page(3).prev_page
    end

    test 'page 5' do
      assert_nil @array.page(5).prev_page
    end
  end

  sub_test_case '#count' do
    test 'page 1' do
      assert_equal 25, @array.page.count
    end

    test 'page 2' do
      assert_equal 25, @array.page(2).count
    end
  end

  sub_test_case 'when setting total count explicitly' do
    test 'array 1..10, page 5, per 10, total_count 9999' do
      arr = Kaminari::PaginatableArray.new((1..10).to_a, total_count: 9999).page(5).per(10)

      assert_equal 10, arr.count
      assert_equal 1, arr.first
      assert_equal 5, arr.current_page
      assert_equal 9999, arr.total_count
    end

    test 'array 1..15, page 1, per 10, total_count 15' do
      arr = Kaminari::PaginatableArray.new((1..15).to_a, total_count: 15).page(1).per(10)

      assert_equal 10, arr.count
      assert_equal 1, arr.first
      assert_equal 1, arr.current_page
      assert_equal 15, arr.total_count
    end

    test 'array 1..25, page 2, per 10, total_count 15' do
      arr = Kaminari::PaginatableArray.new((1..25).to_a, total_count: 15).page(2).per(10)

      assert_equal 5, arr.count
      assert_equal 11, arr.first
      assert_equal 2, arr.current_page
      assert_equal 15, arr.total_count
    end
  end
end
