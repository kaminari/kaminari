require 'spec_helper'

if defined? ActiveRecord
  describe Kaminari::ActiveRecordRelationMethods, :type => :model do
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

      context "when the scope is cloned" do
        it "should reset total_coount momoization" do
          expect(User.page.tap(&:total_count).where(:name => 'author').total_count).to eq(1)
        end
      end

      context "when the scope includes an order which references a generated column" do
        it "should successfully count the results" do
          expect(@author.readers.by_read_count.page(1).total_count).to eq(@readers.size)
        end
      end

      context "when the scope use conditions on includes" do
        it "should keep includes and successfully count the results" do
          # Only @author and @author2 have books titled with the title00x partern
          if ActiveRecord::VERSION::STRING >= "4.1.0"
            expect(User.includes(:books_authored).references(:books).where("books.title LIKE 'title00%'").page(1).total_count).to eq(2)
          else
            expect(User.includes(:books_authored).where("books.title LIKE 'title00%'").page(1).total_count).to eq(2)
          end
        end
      end

      context 'when the Relation has custom select clause' do
        specify do
          expect { User.select('*, 1 as one').page(1).total_count }.not_to raise_exception
        end
      end

      context "when total_count receives options" do
        it "should return a distinct total count for rails < 4.1" do
          if ActiveRecord::VERSION::STRING < "4.1.0"
            expect(User.page(1).total_count(:name, :distinct => true)).to eq(4)
          end
        end

        it "should ignore the options for rails 4.1+" do
          if ActiveRecord::VERSION::STRING >= "4.1.0"
            expect(User.page(1).total_count(:name, :distinct => true)).to eq(7)
          end
        end
      end

      if ActiveRecord::VERSION::STRING < '4.1.0'
        context 'when count receives options' do
          it 'should return a distinct set by column for rails < 4.1' do
            expect(User.page(1).count(:name, :distinct => true)).to eq(4)
          end
        end
      end

      context "when the scope returns an ActiveSupport::OrderedHash" do
        it "should not throw exception by passing options to count" do
          expect {
            @author.readers.by_read_count.page(1).total_count(:name, :distinct => true)
          }.not_to raise_exception
        end
      end
    end
  end
end
