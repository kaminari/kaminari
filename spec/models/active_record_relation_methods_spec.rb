require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Kaminari::ActiveRecordRelationMethods do
  describe '#total_count' do
    before do
      @author = User.create! :name => 'author'
      @author2 = User.create! :name => 'author2'
      @author3 = User.create! :name => 'author3'
      @books = 2.times.map {|i| @author.books_authored.create!(:title => "title%03d" % i) }
      @books2 = 3.times.map {|i| @author2.books_authored.create!(:title => "title%03d" % i) }
      @books3 = 4.times.map {|i| @author3.books_authored.create!(:title => "subject%03d" % i) }
      @readers = 4.times.map { User.create! :name => 'reader' }
      @books.each { |book| book.readers << @readers }
      @books2.each { |book| book.readers << @readers.take(2) }
    end

    context "when the scope includes an order which references a generated column" do
      it "should successfully count the results" do
        @author.readers.by_read_count.page(1).total_count.should == @readers.size
      end
    end
    context "when the scope use conditions on includes" do
      it "should keep includes and successfully count the results" do
        # Only @author and @author2 have books titled with the title00x partern
        User.includes(:books_authored).where("books.title LIKE 'title00%'").page(1).total_count.should == 2
      end
    end

    context "when the scope responds to smart_count" do
      module SmartCount
        def smart_count
          count_by_sql("SELECT COUNT(*) FROM (#{scoped.to_sql}) AS count_table")
        end
      end

      it "should call smart_count on scope and return the given value" do
        # only 2 users have read more than two books
        User.joins(:readerships).read_count_at_least(3).extending(SmartCount).page(1).total_count.should == 2
      end
    end
  end
end
