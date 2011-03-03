require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'mongoid'
require File.expand_path('../../lib/kaminari/models/mongoid_extension', File.dirname(__FILE__))

describe Kaminari::MongoidExtension do
  before :all do
    class Developer
      include ::Mongoid::Document
      field :salary, :type => Integer
    end
  end
  before do
    stub(subject).count { 300 } # in order to avoid DB access...
  end

  describe '#page' do
    context 'page 1' do
      subject { Developer.page 1 }
      it { should be_a Mongoid::Criteria }
      its(:current_page) { should == 1 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 12 }
      it { should skip(0) }
    end

    context 'page 2' do
      subject { Developer.page 2 }
      it { should be_a Mongoid::Criteria }
      its(:current_page) { should == 2 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 12 }
      it { should skip 25 }
    end

    context 'page "foobar"' do
      subject { Developer.page 'foobar' }
      it { should be_a Mongoid::Criteria }
      its(:current_page) { should == 1 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 12 }
      it { should skip 0 }
    end

    context 'with criteria before' do
      subject { Developer.where(:salary => 1).page 2 }
      its(:selector) { should == {:salary => 1} }
      its(:current_page) { should == 2 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 12 }
      it { should skip 25 }
    end

    context 'with criteria after' do
      subject { Developer.page(2).where(:salary => 1) }
      its(:selector) { should == {:salary => 1} }
      its(:current_page) { should == 2 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 12 }
      it { should skip 25 }
    end

  end

  describe '#per' do
    subject { Developer.page(2).per(10) }
    it { should be_a Mongoid::Criteria }
    its(:current_page) { should == 2 }
    its(:limit_value) { should == 10 }
    its(:num_pages) { should == 30 }
    it { should skip 10 }
  end
end
