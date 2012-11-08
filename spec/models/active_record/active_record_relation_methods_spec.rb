require 'spec_helper'

if defined? ActiveRecord
  describe Kaminari::ActiveRecordRelationMethods do
    describe '#page' do
      it "should accept no arguments" do
        lambda { User.page }.should_not raise_error
      end

      it "should accept 1 argument" do
        lambda { User.page(5) }.should_not raise_error
      end

      it "should not accept 2 arguments" do
        lambda { User.page(5,2) }.should raise_error(ArgumentError)
      end
    end

    describe '#total_count' do
      before do
        @author = User.create! :name => 'author'
        @author2 = User.create! :name => 'author2'
        @author3 = User.create! :name => 'author3'
        @books = 2.times.map {|i| @author.books_authored.create!(:title => "title%03d" % i) }
        @books2 = 3.times.map {|i| @author2.books_authored.create!(:title => "title%03d" % i) }
        @books3 = 4.times.map {|i| @author3.books_authored.create!(:title => "subject%03d" % i) }
        @readers = 4.times.map { User.create! :name => 'reader' }
        @books.each {|book| book.readers << @readers }
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
      context "when total_count receives options" do
        it "should return a distinct total count" do
          User.page(1).total_count(:name, :distinct => true).should == 4
        end
      end
      context "when count receives options" do
        it "should return a distinct set by column" do
          User.page(1).count(:name, :distinct => true).should == 4
        end
      end
      context "when the scope returns an ActiveSupport::OrderedHash" do
        it "should not throw exception by passing options to count" do
          lambda {
            @author.readers.by_read_count.page(1).total_count(:name, :distinct => true)
          }.should_not raise_exception
        end
      end
      context "when there are multiple conditions for one attribute" do
        it "should successfully count the results" do
          scope = User.where(:name => ['author', 'author2']).where(:name => ['author2', 'author3'])
          scope.page(1).total_count.should == 1
        end
      end
    end
  end
end
