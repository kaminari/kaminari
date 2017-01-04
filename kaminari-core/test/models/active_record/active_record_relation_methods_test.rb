# frozen_string_literal: true
require 'test_helper'

if defined? ActiveRecord
  class ActiveRecordRelationMethodsTest < ActiveSupport::TestCase
    sub_test_case '#total_count' do
      setup do
        @author = User.create! name: 'author'
        @author2 = User.create! name: 'author2'
        @author3 = User.create! name: 'author3'
        @books = 2.times.map {|i| @author.books_authored.create!(title: "title%03d" % i) }
        @books2 = 3.times.map {|i| @author2.books_authored.create!(title: "title%03d" % i) }
        @books3 = 4.times.map {|i| @author3.books_authored.create!(title: "subject%03d" % i) }
        @readers = 4.times.map { User.create! name: 'reader' }
        @books.each {|book| book.readers << @readers }
      end
      teardown do
        Book.delete_all
        User.delete_all
        Readership.delete_all
      end

      test 'total_count on not yet loaded Relation' do
        assert_equal 0, User.where('1 = 0').page(1).total_count
        assert_equal 0, User.where('1 = 0').page(1).per(10).total_count
        assert_equal 7, User.page(1).total_count
        assert_equal 7, User.page(1).per(10).total_count
        assert_equal 7, User.page(2).total_count
        assert_equal 7, User.page(2).per(10).total_count
        assert_equal 7, User.page(2).per(2).total_count
      end

      test 'total_count on loded Relation' do
        assert_equal 0, User.where('1 = 0').page(1).load.total_count
        assert_equal 0, User.where('1 = 0').page(1).per(10).load.total_count
        assert_equal 7, User.page(1).load.total_count
        assert_equal 7, User.page(1).per(10).load.total_count
        assert_equal 7, User.page(2).load.total_count
        assert_equal 7, User.page(2).per(10).load.total_count
        assert_equal 7, User.page(2).per(2).load.total_count
      end

      test 'it should reset total_count memoization when the scope is cloned' do
        assert_equal 1, User.page.tap(&:total_count).where(name: 'author').total_count
      end

      test 'it should successfully count the results when the scope includes an order which references a generated column' do
        assert_equal @readers.size, @author.readers.by_read_count.page(1).total_count
      end

      test 'it should keep includes and successfully count the results when the scope use conditions on includes' do
        # Only @author and @author2 have books titled with the title00x pattern
        assert_equal 2, User.includes(:books_authored).references(:books).where("books.title LIKE 'title00%'").page(1).total_count
      end

      test 'when the Relation has custom select clause' do
        assert_nothing_raised do
          User.select('*, 1 as one').page(1).total_count
        end
      end

      test 'it should ignore the options for rails 4.1+ when total_count receives options' do
        assert_equal 7, User.page(1).total_count(:name, distinct: true)
      end

      test 'it should not throw exception by passing options to count when the scope returns an ActiveSupport::OrderedHash' do
        assert_nothing_raised do
          @author.readers.by_read_count.page(1).total_count(:name, distinct: true)
        end
      end

      test "it counts the number of rows, not the number of keys, with an alias field" do
        @books.each {|book| book.readers << @readers[0..1] }

        assert_equal 8, Readership.select('user_id, count(user_id) as read_count, book_id').group(:user_id, :book_id).page(1).total_count
      end

      test "it counts the number of rows, not the number of keys without an alias field" do
        @books.each {|book| book.readers << @readers[0..1] }

        assert_equal 8, Readership.select('user_id, count(user_id), book_id').group(:user_id, :book_id).page(1).total_count
      end

      test "throw an exception when calculating total_count when the query includes column aliases used by a group-by clause" do
        assert_equal 3, Book.joins(authorships: :user).select("users.name as author_name").group('users.name').page(1).total_count
      end
    end
  end
end
