require 'spec_helper'
require 'mongo_mapper'
require 'kaminari/models/mongo_mapper_extension'

describe Kaminari::MongoMapperExtension do
  before do
    begin
      MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
      MongoMapper.database = "kaminari_test"
      class Developer
        include ::MongoMapper::Document
        key :salary, Integer
      end

      stub(subject).count { 300 } # in order to avoid DB access...
    rescue Mongo::ConnectionFailure
      pending 'can not connect to MongoDB'
    end
  end

  describe '#page' do
    context 'page 1' do
      subject { Developer.page(1) }
      it { should be_a Plucky::Query }
      its(:current_page) { should == 1 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 12 }
      it { should skip(0) }
    end

    context 'page 2' do
      subject { Developer.page 2 }
      it { should be_a Plucky::Query }
      its(:current_page) { should == 2 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 12 }
      it { should skip 25 }
    end

    context 'page "foobar"' do
      subject { Developer.page 'foobar' }
      it { should be_a Plucky::Query }
      its(:current_page) { should == 1 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 12 }
      it { should skip 0 }
    end

    context 'with criteria before' do
      it "should have the proper criteria source" do
        Developer.where(:salary => 1).page(2).criteria.source.should == {:salary => 1}
      end

      subject { Developer.where(:salary => 1).page 2 }
      its(:current_page) { should == 2 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 12 }
      it { should skip 25 }
    end

    context 'with criteria after' do
      it "should have the proper criteria source" do
        Developer.where(:salary => 1).page(2).criteria.source.should == {:salary => 1}
      end

      subject { Developer.page(2).where(:salary => 1) }
      its(:current_page) { should == 2 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 12 }
      it { should skip 25 }
    end
  end

  describe '#per' do
    subject { Developer.page(2).per(10) }
    it { should be_a Plucky::Query }
    its(:current_page) { should == 2 }
    its(:limit_value) { should == 10 }
    its(:num_pages) { should == 30 }
    it { should skip 10 }
  end
end
