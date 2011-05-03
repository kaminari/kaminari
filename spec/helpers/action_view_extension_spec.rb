require File.expand_path('../spec_helper', File.dirname(__FILE__))
include Kaminari::ActionViewExtension

describe 'Kaminari::ActionViewExtension' do
  describe '#paginate' do
    before do
      @author = User.create! :name => 'author'
      @books = 2.times.map { @author.books_authored.create! }
      @books = Book.page(1)
    end
    subject { paginate( @books ) }
    it { should be_a(String) }

    context "escaping the pagination for javascript" do
      it "should escape for javascript" do
        lambda { escape_javascript( paginate( @books ) ) }.should_not raise_error
      end
    end
  end
end
