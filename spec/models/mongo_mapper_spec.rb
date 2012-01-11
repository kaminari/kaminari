require 'spec_helper'
require 'mongo_mapper'
require 'kaminari/models/mongo_mapper_extension'

describe Kaminari::MongoMapperExtension do
  
  before do
    begin
      MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
      MongoMapper.database = "kaminari_test"
      class MongoMapperExtension_Developer
        include ::MongoMapper::Document
        key :salary, Integer
      end
    rescue Mongo::ConnectionFailure
      pending 'can not connect to MongoDB'
    end
  end

  before(:each) do
    MongoMapperExtension_Developer.destroy_all
    41.times { MongoMapperExtension_Developer.create!({:salary => 1}) }
  end

  describe '#page' do
    context 'page 1' do
      subject { MongoMapperExtension_Developer.page(1) }
      it { should be_a Plucky::Query }
      its(:current_page) { should == 1 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 2 }
      its(:current_page_count) { should == 25 }
      it { should skip(0) }
    end

    context 'page 2' do
      subject { MongoMapperExtension_Developer.page 2 }
      it { should be_a Plucky::Query }
      its(:current_page) { should == 2 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 2 }
      its(:current_page_count) { should == 16 }
      it { should skip 25 }
    end

    context 'page "foobar"' do
      subject { MongoMapperExtension_Developer.page 'foobar' }
      it { should be_a Plucky::Query }
      its(:current_page) { should == 1 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 2 }
      its(:current_page_count) { should == 25 }
      it { should skip 0 }
    end

    context 'with criteria before' do
      it "should have the proper criteria source" do
        MongoMapperExtension_Developer.where(:salary => 1).page(2).criteria.source.should == {:salary => 1}
      end

      subject { MongoMapperExtension_Developer.where(:salary => 1).page 2 }
      its(:current_page) { should == 2 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 2 }
      its(:current_page_count) { should == 16 }
      it { should skip 25 }
    end

    context 'with criteria after' do
      it "should have the proper criteria source" do
        MongoMapperExtension_Developer.where(:salary => 1).page(2).criteria.source.should == {:salary => 1}
      end

      subject { MongoMapperExtension_Developer.page(2).where(:salary => 1) }
      its(:current_page) { should == 2 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 2 }
      its(:current_page_count) { should == 16 }
      it { should skip 25 }
    end
  end

  describe '#per' do
    subject { MongoMapperExtension_Developer.page(2).per(10) }
    it { should be_a Plucky::Query }
    its(:current_page) { should == 2 }
    its(:limit_value) { should == 10 }
    its(:num_pages) { should == 5 }
    its(:current_page_count) { should == 10 }
    it { should skip 10 }
  end
end
