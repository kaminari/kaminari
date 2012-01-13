require 'spec_helper'
require 'mongoid'
require 'kaminari/models/mongoid_extension'

describe Kaminari::MongoidExtension do

  before do
    begin
      Mongoid.configure do |config|
        config.master = Mongo::Connection.new.db("kaminari_test")
      end
      class MongoidExtensionDeveloper
        include ::Mongoid::Document
        field :salary, type: Integer
      end
    rescue Mongo::ConnectionFailure
      pending 'can not connect to MongoDB'
    end
  end

  before(:each) do
    MongoidExtensionDeveloper.all.destroy
    41.times do
      MongoidExtensionDeveloper.create!({:salary => 1})
    end
  end

  describe '#page' do
    
    context 'page 1' do
      subject { MongoidExtensionDeveloper.page 1 }
      it { should be_a Mongoid::Criteria }
      its(:current_page) { should == 1 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 2 }
      its(:current_page_count) { should == 25 }
      it { should skip(0) }
    end

    context 'page 2' do
      subject { MongoidExtensionDeveloper.page 2 }
      it { should be_a Mongoid::Criteria }
      its(:current_page) { should == 2 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 2 }
      its(:current_page_count) { should == 16 }
      it { should skip 25 }
    end

    context 'page "foobar"' do
      subject { MongoidExtensionDeveloper.page 'foobar' }
      it { should be_a Mongoid::Criteria }
      its(:current_page) { should == 1 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 2 }
      its(:current_page_count) { should == 25 }
      it { should skip 0 }
    end

    context 'with criteria before' do
      subject { MongoidExtensionDeveloper.where(:salary => 1).page 2 }
      its(:selector) { should == {:salary => 1} }
      its(:current_page) { should == 2 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 2 }
      its(:current_page_count) { should == 16 }
      it { should skip 25 }
    end

    context 'with criteria after' do
      subject { MongoidExtensionDeveloper.page(2).where(:salary => 1) }
      its(:selector) { should == {:salary => 1} }
      its(:current_page) { should == 2 }
      its(:limit_value) { should == 25 }
      its(:num_pages) { should == 2 }
      its(:current_page_count) { should == 16 }
      it { should skip 25 }
    end
  end

  describe '#per' do
    subject { MongoidExtensionDeveloper.page(2).per(10) }
    it { should be_a Mongoid::Criteria }
    its(:current_page) { should == 2 }
    its(:limit_value) { should == 10 }
    its(:num_pages) { should == 5 }
    its(:current_page_count) { should == 10 }
    it { should skip 10 }
  end

  describe '#page in embedded documents' do
    before :all do
      class MongoMongoidExtensionDeveloper
        include ::Mongoid::Document
        field :salary, :type => Integer
        embeds_many :frameworks
      end

      class Framework
        include ::Mongoid::Document
        field :name, :type => String
        field :language, :type => String
        embedded_in :mongo_mongoid_extension_developer
      end
    end

    before :all do
      @mongo_developer = MongoMongoidExtensionDeveloper.new
      @mongo_developer.frameworks.new(:name => "rails", :language => "ruby")
      @mongo_developer.frameworks.new(:name => "merb", :language => "ruby")
      @mongo_developer.frameworks.new(:name => "sinatra", :language => "ruby")
      @mongo_developer.frameworks.new(:name => "cakephp", :language => "php")
      @mongo_developer.frameworks.new(:name => "tornado", :language => "python")
    end

    context 'page 1' do
      subject { @mongo_developer.frameworks.page(1).per(1) }
      it { should be_a Mongoid::Criteria }
      its(:total_count) { should == 5 }
      its(:limit_value) { should == 1 }
      its(:current_page) { should == 1 }
      its(:num_pages) { should == 5 }
      its(:current_page_count) { should == 1 }
    end

    context 'with criteria after' do
      subject { @mongo_developer.frameworks.page(1).per(2).where(:language => "ruby") }
      it { should be_a Mongoid::Criteria }
      its(:total_count) { should == 3 }
      its(:limit_value) { should == 2 }
      its(:current_page) { should == 1 }
      its(:num_pages) { should == 2 }
      its(:current_page_count) { should == 2 }
    end

    context 'with criteria before' do
      subject { @mongo_developer.frameworks.where(:language => "ruby").page(1).per(2) }
      it { should be_a Mongoid::Criteria }
      its(:total_count) { should == 3 }
      its(:limit_value) { should == 2 }
      its(:current_page) { should == 1 }
      its(:num_pages) { should == 2 }
      its(:current_page_count) { should == 2 }
    end
  end
end
