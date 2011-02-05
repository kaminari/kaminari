require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Kaminari::ActiveRecord do
  before :all do
    User.delete_all
    1.upto(20) {|i| User.create! :name => "user#{'%02d' % i}" }
  end

  describe '#page' do
    shared_examples_for 'the first page' do
      it { should have(10).users }
      its('first.name') { should == 'user01' }
    end

    shared_examples_for 'blank page' do
      it { should have(0).users }
    end

    context 'page 1' do
      subject { User.page 1 }
      it_should_behave_like 'the first page'
    end

    context 'page 2' do
      subject { User.page 2 }
      it { should have(10).users }
      its('first.name') { should == 'user11' }
    end

    context 'page without an argument' do
      subject { User.page }
      it_should_behave_like 'the first page'
    end

    context 'page < 1' do
      subject { User.page 0 }
      it_should_behave_like 'the first page'
    end

    context 'page > max page' do
      subject { User.page 3 }
      it_should_behave_like 'blank page'
    end
  end

  describe '#per' do
    context 'page 1 per 5' do
      subject { User.page(1).per(5) }
      it { should have(5).users }
      its('first.name') { should == 'user01' }
    end
  end

  describe '#num_pages' do
    context 'per 10' do
      subject { User.page.num_pages }
      it { should == 2 }
    end

    context 'per 7' do
      subject { User.page(2).per(7).num_pages }
      it { should == 3 }
    end

    context 'per 65536' do
      subject { User.page(50).per(65536).num_pages }
      it { should == 1 }
    end
  end

  describe '#current_page' do
    context 'page 1' do
      subject { User.page.current_page }
      it { should == 1 }
    end

    context 'page 2' do
      subject { User.page(2).per(3).current_page }
      it { should == 2 }
    end
  end
end
