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

      test 'total_count on loaded Relation' do
        assert_equal 0, User.where('1 = 0').page(1).load.total_count
        assert_equal 0, User.where('1 = 0').page(1).per(10).load.total_count
        assert_equal 7, User.page(1).load.total_count
        assert_equal 7, User.page(1).per(10).load.total_count
        assert_equal 7, User.page(2).load.total_count
        assert_equal 7, User.page(2).per(10).load.total_count
        assert_equal 7, User.page(2).per(2).load.total_count

        old_max_per_page = User.max_per_page
        User.max_paginates_per(5)
        assert_equal 7, User.page(1).per(100).load.total_count
        assert_equal 7, User.page(2).per(100).load.total_count
        User.max_paginates_per(old_max_per_page)
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

      test 'total_count is calculable with page 1 per "5" (the string)' do
        assert_equal 7, User.page(1).per('5').load.total_count
      end

      test 'calculating total_count with GROUP BY ... HAVING clause' do
        assert_equal 2, Authorship.group(:user_id).having("COUNT(book_id) >= 3").page(1).total_count
      end

      test 'calculating total_count with GROUP BY ... HAVING clause with model that has default scope' do
        assert_equal 2, CurrentAuthorship.group(:user_id).having("COUNT(book_id) >= 3").page(1).total_count
      end

      test 'calculating STI total_count with GROUP BY clause' do
        [
          ['Fenton',   Dog],
          ['Bob',      Dog],
          ['Garfield', Cat],
          ['Bob',      Cat],
          ['Caine', Insect]
        ].each { |name, type| type.create!(name: name) }

        assert_equal 3, Mammal.group(:name).page(1).total_count
      end

      test 'total_count with max_pages does not add LIMIT' do
        begin
          subscriber = ActiveSupport::Notifications.subscribe 'sql.active_record' do |_, __, ___, ____, payload|
            assert_not_match(/LIMIT/, payload[:sql])
          end

          assert_equal 7, User.page.total_count
        ensure
          ActiveSupport::Notifications.unsubscribe subscriber
        end
      end

      test 'total_count with max_pages adds "LIMIT (max_pages * per_page)" to the count query' do
        begin
          subscriber = ActiveSupport::Notifications.subscribe 'sql.active_record' do |_, __, ___, ____, payload|
            assert_match(/LIMIT/, payload[:sql])
          end

          User.max_pages 10

          assert_equal 7, User.page.total_count
        ensure
          User.max_pages nil
          ActiveSupport::Notifications.unsubscribe subscriber
        end
      end
    end
    sub_test_case '::CursorPaginatable' do
      setup do
        @newborn = User.create! name: nil, age: 0
        @baby = User.create! name: 'Alex', age: 1
        @toddler = User.create! name: 'Pat', age: 2
        @child = User.create! name: 'Alex', age: 5
        @teen = User.create! name: 'Pat', age: 17
        @adult = User.create! name: 'Alex', age: 35
        @elder = User.create! name: 'Pat', age: 79
        @werewolf = User.create! name: nil, age: 151
        @vampire = User.create! name: 'Alex', age: 710
        @another_vampire = User.create! name: 'Alex', age: 710
        @god = User.create! name: 'Pat', age: nil

        3.times.each{@adult.books_authored << (Book.create! title: nil)}
        1.times.each{@elder.books_authored << (Book.create! title: nil)}
        1.times.each{@vampire.books_authored << (Book.create! title: nil)}

        @books = Book.order(:id).all.to_a

        t = Time.at(Time.now.to_f.floor)
        @events = []
        @events << (Event.create! time: t - 5e-6.seconds)
        @events << (Event.create! time: t - 1e-6.seconds)
        @events << (Event.create! time: t)
        @events << (Event.create! time: t + 1e-6.seconds)
        @events << (Event.create! time: t + 5e-6.seconds)

        @large_nulls = {
          mysql: false,
          mysql2: false,
          sqlite: false,
          postgresql: true
        }.fetch(User.connection.adapter_name.downcase.to_sym)
      end
      teardown do
        User.delete_all
      end

      test 'page by cursor should give first records' do
        first_expected = @large_nulls ? @newborn : @god
        assert [first_expected] == User.order(:age).page_by_cursor.per(1).to_a
      end

      test 'page by cursor should give first records in descending order' do
        first_expected = @large_nulls ? @god : @vampire
        assert [first_expected] == User.order(age: :desc).page_by_cursor.per(1).to_a
      end

      test 'page after nil should give first records' do
        first_expected = @large_nulls ? @newborn : @god
        assert [first_expected] == User.order(:age).page_after.per(1).to_a
      end

      test 'page before nil should also give first records' do
        first_expected = @large_nulls ? @newborn : @god
        assert [first_expected] == User.order(:age).page_before.per(1).to_a
      end

      test 'page after cursor with null valued column should give next results' do
        cursor = Base64.strict_encode64({name: @newborn.name, age: @newborn.age, id: @newborn.id}.to_json)
        assert [@werewolf] == User.order(:name).order(:age).page_after(cursor).per(1).to_a
      end

      test 'page after should resolve ambiguity with primary key' do
        cursor = Base64.strict_encode64({name: @vampire.name, age: @vampire.age, id: @vampire.id}.to_json)
        assert [@another_vampire] == User.order('name, age').page_after(cursor).per(1).to_a
      end

      test 'cursor paging should include remaining records with null values' do
        cursor = Base64.strict_encode64({name: @baby.name, age: @baby.age, id: @baby.id}.to_json)
        page_method = @large_nulls ? :page_after : :page_before
        results = User.order('name').send(page_method, cursor).per(100)
        assert results.include? @werewolf
        assert results.include? @newborn
      end

      test 'cursor paging should exclude prior records with null values' do
        cursor = Base64.strict_encode64({name: @baby.name, age: @baby.age, id: @baby.id}.to_json)
        page_method = @large_nulls ? :page_before : :page_after
        results = User.order('name').send(page_method, cursor).per(100)
        assert !results.include?(@werewolf)
        assert !results.include?(@newborn)
      end

      test 'page after cursor works based on primary key alone' do
        assert [@books.third, @books.fourth, @books.fifth] == Book.page_after({id: @books.second.id}).per(5).to_a
      end

      test 'page before cursor works based on primary key alone' do
        assert [@books.first, @books.second, @books.third] == Book.page_before({id: @books.fourth.id}).per(5).to_a
      end

      test 'page by cursor does not change explicit descending id' do
        assert [@another_vampire, @vampire] == User.order(:age).order(id: :desc).page_after({age: @werewolf.age, id: @werewolf.id}).per(2).to_a
      end

      test 'page by cursor uses microsecond precision for timestamp field' do
        events = Event.order(:time).order(:id)
        cursor = events.page_after.per(2).end_cursor
        assert [@events.third, @events.fourth, @events.fifth] == events.page_after(cursor).per(5).to_a
      end

      if (Rails.version >= '6.1.0' && ENV['DB'] == 'postgresql') || (Rails.version >= '7.0.0' && ENV['DB'] == 'sqlite3')
        test 'page after cursor works with nulls first (ascending)' do
          users = User.order(User.arel_table[:name].asc.nulls_first).page_after
          assert [@newborn, @werewolf] == users.per(2).to_a
        end

        test 'page after cursor works with nulls first (descending)' do
          users = User.order(User.arel_table[:name].desc.nulls_first).page_after
          assert [@newborn, @werewolf] == users.per(2).to_a
        end

        test 'page after cursor works with nulls last (ascending)' do
          users = User.order(User.arel_table[:name].asc.nulls_last).page_after({name: @god.name, id: @god.id})
          assert [@newborn, @werewolf] == users.per(2).to_a
        end

        test 'page after cursor works with nulls last (descending)' do
          users = User.order(User.arel_table[:name].desc.nulls_last).page_after({name: @another_vampire.name, id: @another_vampire.id})
          assert [@newborn, @werewolf] == users.per(2).to_a
        end
      end
    end
  end
end
