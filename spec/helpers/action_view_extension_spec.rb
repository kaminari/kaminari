require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe 'Kaminari::ActionViewExtension' do
  before do
    50.times {|i| User.create! :name => "user#{i}"}
  end
  describe '#paginate' do
    before do
      @users = User.page(1)
    end
    subject { helper.paginate @users, :params => {:controller => 'users', :action => 'index'} }
    it { should be_a String }

    context 'escaping the pagination for javascript' do
      it 'should escape for javascript' do
        lambda { escape_javascript(helper.paginate @users, :params => {:controller => 'users', :action => 'index'}) }.should_not raise_error
      end
    end
  end

  describe '#link_to_next_page' do
    context 'having more page' do
      before do
        @users = User.page(1)
      end
      subject { helper.link_to_next_page @users, 'More', :params => {:controller => 'users', :action => 'index'} }
      it { should be_a String }
    end
    context 'the last page' do
      before do
        @users = User.page(2)
      end
      subject { helper.link_to_next_page @users, 'More', :params => {:controller => 'users', :action => 'index'} }
      it { should_not be }
    end
  end
end
