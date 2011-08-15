require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'dm-core'
require 'kaminari/models/data_mapper_extension'

describe Kaminari::DataMapperExtension do
  before :all do
    DataMapper.setup(:default, 'sqlite::memory:')
    class Developer
      include ::DataMapper::Resource
      property :id, Serial
      property :salary, Integer
    end
  end
  before do
    stub(subject).count { 300 } # in order to avoid DB access...
  end

  describe '#page' do
    context 'page 1' do
      subject { Developer.page(1) }
      it { should be_a DataMapper::Collection }
      its(:current_page) { should == 1 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 12 }
      it { should offset(0) }
    end

    context 'page 2' do
      subject { Developer.page 2 }
      it { should be_a DataMapper::Collection }
      its(:current_page) { should == 2 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 12 }
      it { should offset 25 }
    end

    context 'page "foobar"' do
      subject { Developer.page 'foobar' }
      it { should be_a DataMapper::Collection }
      its(:current_page) { should == 1 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 12 }
      it { should offset 0 }
    end

    context 'page 1 with another conditions' do
      subject { Developer.page(2) }
      it { should be_a DataMapper::Collection }
      its(:current_page) { should == 2 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 12 }
      it { should offset(25) }
    end
  end

  describe '#per' do
    subject { Developer.page(2).per(10) }
    it { should be_a DataMapper::Collection }
    its(:current_page) { should == 2 }
    its(:limit_value) { should == 10 }
    its(:num_pages) { should == 30 }
    it { should offset 10 }
  end
end
