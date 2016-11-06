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

    test 'it does not make count queires after calling #each' do
      @scope = User.page(1).without_count
      @scope.each

      assert_no_queries do
        assert_not @scope.last_page?
      end
      assert_no_queries do
        assert_not @scope.out_of_range?
      end
    end

    test 'it does not make count queires after calling #last_page? or #out_of_range?' do
      @scope = User.page(1).without_count

      assert_not @scope.last_page?
      assert_not @scope.out_of_range?
      assert_no_queries { @scope.each }
    end

    test 'when on the first page' do
      @users = User.page(1).without_count.load

      assert_equal 25, @users.size
      assert_equal 25, @users.each.size
      assert_not @users.last_page?
      assert_not @users.out_of_range?
    end

    test 'when on the first page showing 26 elements' do
      @users = User.page(1).per(26).without_count.load

      assert_equal 26, @users.size
      assert_equal 26, @users.each.size
      assert @users.last_page?
      assert_not @users.out_of_range?
    end

    test 'when on the last page' do
      @users = User.page(2).without_count.load

      assert_equal 1, @users.size
      assert_equal 1, @users.each.size
      assert @users.last_page?
      assert_not @users.out_of_range?
    end

    test 'when out of range' do
      @users = User.page(3).without_count.load

      assert_equal 0, @users.size
      assert_equal 0, @users.each.size
      assert_not @users.last_page?
      assert @users.out_of_range?
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
