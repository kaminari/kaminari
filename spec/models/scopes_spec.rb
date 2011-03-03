require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Kaminari::ActiveRecordExtension do
  before :all do
    User.delete_all
    1.upto(100) {|i| User.create! :name => "user#{'%03d' % i}", :age => (i / 10)}
  end

  describe '#page' do
    shared_examples_for 'the first page' do
      it { should have(25).users }
      its('first.name') { should == 'user001' }
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
      it { should have(25).users }
      its('first.name') { should == 'user026' }
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
      subject { User.page 5 }
      it_should_behave_like 'blank page'
    end
  end

  describe '#per' do
    context 'page 1 per 5' do
      subject { User.page(1).per(5) }
      it { should have(5).users }
      its('first.name') { should == 'user001' }
    end
  end

  describe '#num_pages' do
    context 'per 25 (default)' do
      subject { User.page }
      its(:num_pages) { should == 4 }
    end

    context 'per 7' do
      subject { User.page(2).per(7) }
      its(:num_pages) { should == 15 }
    end

    context 'per 65536' do
      subject { User.page(50).per(65536) }
      its(:num_pages) { should == 1 }
    end

    context 'per 0 (using default)' do
      subject { User.page(50).per(0) }
      its(:num_pages) { should == 4 }
    end

    context 'per -1 (using default)' do
      subject { User.page(5).per(-1) }
      its(:num_pages) { should == 4 }
    end

    context 'per "String value that can not be converted into Number" (using default)' do
      subject { User.page(5).per('aho') }
      its(:num_pages) { should == 4 }
    end
  end

  describe '#current_page' do
    context 'page 1' do
      subject { User.page }
      its(:current_page) { should == 1 }
    end

    context 'page 2' do
      subject { User.page(2).per 3 }
      its(:current_page) { should == 2 }
    end
  end

  context 'chained with .group' do
    subject { User.group('age').page(2).per 5 }
    # 0..10
    its(:total_count) { should == 11 }
    its(:num_pages) { should == 3 }
  end

  context 'activerecord descendants' do
    subject { ActiveRecord::Base.descendants }
    its(:length) { should_not == 0 }
  end
end
