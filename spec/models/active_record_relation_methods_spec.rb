require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Kaminari::ActiveRecordRelationMethods do
  describe '#total_count' do
    before do
      @author = User.create! :name => 'author'
      @books = 2.times.map { @author.books_authored.create! }
      @readers = 4.times.map { User.create! :name => 'reader' }
      @books.each {|book| book.readers << @readers }
    end

    context "when the scope includes an order which references a generated column" do
      it "should successfully count the results" do
        @author.readers.by_read_count.page(1).total_count.should == @readers.size
      end
    end
  end
end