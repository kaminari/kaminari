# frozen_string_literal: true

require 'test_helper'

if defined? ActiveRecord
  class PaginableWithoutCountTest < ActiveSupport::TestCase
    def self.startup
      26.times { User.create! }
      super
    end

    def self.shutdown
      User.delete_all
      super
    end

    test 'it does not make count queries after calling #each' do
      @scope = User.page(1).without_count
      @scope.each

      assert_no_queries do
        assert_not @scope.last_page?
      end
      assert_no_queries do
        assert_not @scope.out_of_range?
      end
    end

    [:page_after, :page_before].each do|method|
      test "it does not make count queries after calling #each (#{method})" do
        @scope = User.send(method).without_count
        @scope.each

        assert_no_queries do
          assert_not @scope.last_page?
        end
        assert_no_queries do
          assert_not @scope.out_of_range?
        end
      end
    end

    test 'it does not make count queries after calling #last_page? or #out_of_range?' do
      @scope = User.page(1).without_count

      assert_not @scope.last_page?
      assert_not @scope.out_of_range?
      assert_no_queries { @scope.each }
    end

    [:page_after, :page_before].each do |method|
      test "it does not make count queries after calling #last_page? or #out_of_range? (#{method})" do
        @scope = User.send(method).without_count

        assert_not @scope.last_page?
        assert_not @scope.out_of_range?
        assert_no_queries { @scope.each }
      end
    end

    test '#last_page? returns false when total count == 26 and page size == 25' do
      @users = User.page(1).without_count

      assert_equal 25, @users.size
      assert_equal 25, @users.each.size
      assert_not @users.last_page?
      assert_not @users.out_of_range?
    end

    [:page_after, :page_before].each do |method|
      test "#last_page? returns false when total count == 26 and page size == 25 (#{method})" do
        @users = User.send(method).without_count

        assert_equal 25, @users.size
        assert_equal 25, @users.each.size
        assert_not @users.last_page?
        assert_not @users.out_of_range?
      end
    end

    test '#last_page? returns true when total count == page size' do
      @users = User.page(1).per(26).without_count

      assert_equal 26, @users.size
      assert_equal 26, @users.each.size
      assert @users.last_page?
      assert_not @users.out_of_range?
    end

    test '#last_page? returns true when total count == 26, page size == 25, and page == 2' do
      @users = User.page(2).without_count

      assert_equal 1, @users.size
      assert_equal 1, @users.each.size
      assert @users.last_page?
      assert_not @users.out_of_range?
    end

    test '#out_of_range? returns true when total count == 26, page size == 25, and page == 3' do
      @users = User.page(3).without_count

      assert_equal 0, @users.size
      assert_equal 0, @users.each.size
      assert_not @users.last_page?
      assert @users.out_of_range?
    end

    test 'it works when chained after `where`' do
      @scope = User.where.not(id: nil).page(1).without_count
      @scope.each

      assert_no_queries do
        assert_not @scope.last_page?
      end
      assert_no_queries do
        assert_not @scope.out_of_range?
      end
    end

    test 'regression: call arel first' do
      @users = User.page(1).without_count
      @users.arel

      assert_equal false, @users.last_page?
    end

    [:page_after, :page_before].each do |method|
      test "regression: call arel first (#{method})" do
        @users = User.send(method).without_count
        @users.arel

        assert_equal false, @users.last_page?
      end
    end

    test 'regression: call last page first' do
      @users = User.page(1).without_count

      @users.last_page?
      @users.arel

      assert_equal false, @users.last_page?
    end

    [:page_after, :page_before].each do |method|
      test "regression: call last page first (#{method})" do
        @users = User.send(method).without_count

        @users.last_page?
        @users.arel

        assert_equal false, @users.last_page?
      end
    end

    def assert_no_queries
      subscriber = ActiveSupport::Notifications.subscribe 'sql.active_record' do
        raise 'A SQL query is being made to the db:'
      end
      yield
    ensure
      ActiveSupport::Notifications.unsubscribe subscriber
    end
  end
end
