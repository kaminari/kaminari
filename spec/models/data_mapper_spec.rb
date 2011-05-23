require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'dm-core'
require 'dm-migrations'
require 'dm-aggregates'
require File.expand_path('../../lib/kaminari/models/data_mapper_extension', File.dirname(__FILE__))

describe Kaminari::DataMapperExtension do
  before :all do
    
    DataMapper.setup(:default, 'sqlite::memory:')
    
    class Worker
      include ::DataMapper::Resource
      
      property :id, Serial
      property :name, String, :required => true
      property :age, Integer, :required => true
      
      has n, :projects, :through => Resource
    end
    
    class Project
      include ::DataMapper::Resource
      
      property :id, Serial
      property :name, String, :required => true
      
      has n, :workers, :through => Resource
    end
    
    DataMapper.finalize
    DataMapper.auto_migrate!
    
    #::DataMapper::Model.append_extensions Kaminari::DataMapperExtension::ModelClassMethods
    
    300.times do |i|
      Worker.create(:name => "Worker#{i}", :age => i)
    end
    
    worker0 = Worker[0]
    50.times do |i|
      worker0.projects << Project.create(:name => "Project#{i}")
    end
    worker0.projects.save
    
  end
  
  describe Kaminari::DataMapperExtension::PageScopeMethods do
    context 'has methods' do
		subject{ Kaminari::DataMapperExtension::PageScopeMethods.instance_methods }
		it { should include(:per) }
		it { should include(:current_page) }
		it { should include(:num_pages) }
		it { should include(:limit_value) }
		it { should include(:offset_value) }
		it { should include(:total_count) }
    end
  end
  
  #describe Kaminari::DataMapperExtension::Paginatable do
  #  context 'has methods' do
  #    subject{ Kaminari::DataMapperExtension::Paginatable.instance_methods }
  #    it { should include(:page) }
  #  end
  #end
  
  #shared_examples_for Kaminari::DataMapperExtension::Paginatable do
  #  context 'has methods' do
  #    subject{ Kaminari::DataMapperExtension::Paginatable.instance_methods }
  #    it { should include(:page) }
  #  end
  #end
  
  #describe Kaminari::DataMapperExtension::CollectionInstanceMethods do
  #  it_behaves_like Kaminari::DataMapperExtension::Paginatable
  #end
  
  #describe Kaminari::DataMapperExtension::ModelClassMethods do
  #  it_behaves_like Kaminari::DataMapperExtension::Paginatable
  #end
  
  describe 'Collection' do
    subject{ Worker.all }
    it { should respond_to(:page) }
    it { should_not respond_to(:per) }
  end
  
  describe 'Model' do
    subject{ Worker }
    it { should respond_to(:page) }
    it { should respond_to(:default_per_page) }
    it { should_not respond_to(:per) }
  end

  describe '#page' do
    context 'page 0' do
      subject { Worker.all(:age.gte => 200).page 0 }
      its(:current_page) { should == 1 }
      its('query.limit') { should == 25 }
      its('query.offset') { should == 0 }
      its(:total_count) { should == Worker.count(:age.gte => 200) }
      its(:num_pages) { should == 4 }
    end
    
    context 'page 1' do
      subject { Worker.all(:age.gte => 0).page 1 }
      its(:current_page) { should == 1 }
      its('query.limit') { should == 25 }
      its('query.offset') { should == 0 }
      its(:total_count) { should == 300 }
      its(:num_pages) { should == 12 }
    end

    context 'page 2' do
      subject { Worker.page 2 }
      its(:current_page) { should == 2 }
      its('query.limit') { should == 25 }
      its('query.offset') { should == 25 }
      its(:total_count) { should == 300 }
      its(:num_pages) { should == 12 }
    end

    context 'page "foobar"' do
      subject { Worker.page 'foobar' }
      its(:current_page) { should == 1 }
      its('query.limit') { should == 25 }
      its('query.offset') { should == 0 }
      its(:total_count) { should == 300 }
      its(:num_pages) { should == 12 }
    end

    context 'with criteria before' do
      subject { Worker.all(:age.gt => 100).page 2 }
      #its('query.conditions') { should == {:age.gt => 1} }
      its(:current_page) { should == 2 }
      its('query.limit') { should == 25 }
      its('query.offset') { should == 25 }
      its(:total_count) { should == Worker.count(:age.gt => 100) }
      its(:num_pages) { should == 8 }
    end

    context 'with criteria after' do
      subject { Worker.page(2).all(:age.gt => 100) }
      #its('query.conditions') { should == {:age.gt => 100} }
      its(:current_page) { should == 2 }
      its('query.limit') { should == 25 }
      its('query.offset') { should == 25 }
      its(:total_count) { should == Worker.count(:age.gt => 100) }
      its(:num_pages) { should == 8 }
    end

  end

  describe '#per' do
    context 'on simple query' do
		subject { Worker.page(2).per(10) }
		its(:current_page) { should == 2 }
		its('query.limit') { should == 10 }
		its('query.offset') { should == 10 }
		its(:total_count) { should == 300 }
		its(:num_pages) { should == 30 }
    end
    
    context 'on query with condition' do
      subject { Worker.page(5).all(:age.lte => 100).per(13) }
      its(:current_page) { should == 5 }
      its('query.limit') { should == 13 }
      its('query.offset') { should == 52 }
      its(:total_count) { should == 101 }
      its(:num_pages) { should == 8 }
    end
    
    context 'on query with order' do
      subject { Worker.page(5).all(:age.lte => 100, :order => [:age.asc]).per(13) }
      it('includes worker with age 52') { should include(Worker.first(:age => 52)) }
      it('does not include worker with age 51') { should_not include(Worker.first(:age => 51)) }
      it('includes worker with age 52') { should include(Worker.first(:age => 64)) }
      it('does not include worker with age 51') { should_not include(Worker.first(:age => 65)) }
      its(:current_page) { should == 5 }
      its('query.limit') { should == 13 }
      its('query.offset') { should == 52 }
      its(:total_count) { should == 101 }
      its(:num_pages) { should == 8 }
    end
    
    context 'on chained queries' do
      subject { Worker.all(:age.gte => 50).page(3).all(:age.lte => 100).per(13) }
      its(:current_page) { should == 3 }
      its('query.limit') { should == 13 }
      its('query.offset') { should == 26 }
      its(:total_count) { should == 51 }
      its(:num_pages) { should == 4 }
    end
    
    context 'on query on association' do
      subject { Worker[0].projects.page(3).all(:name.like => 'Project%').per(5) }
      its(:current_page) { should == 3 }
      its('query.limit') { should == 5 }
      its('query.offset') { should == 10 }
      its(:total_count) { should == 50 }
      its(:num_pages) { should == 10 }
    end
    
    context 'on query with association conditions' do
      subject { Worker.page(3).all(:projects => Project.all).per(5) }
      its(:current_page) { should == 3 }
      its('query.limit') { should == 5 }
      its('query.offset') { should == 10 }
      its(:total_count) { should == 50 }
      its(:num_pages) { should == 10 }
    end
  end


end
