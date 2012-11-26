require 'spec_helper'

if defined? MongoMapper
  describe Kaminari::MongoMapperExtension do
    before(:each) do
      User.destroy_all
      100.times { User.create!({:salary => 1}) }
    end

    describe '#page' do
      context 'page 1' do
        subject { User.page(1) }
        it { should be_a Plucky::Query }
        its(:current_page) { should == 1 }
        its(:limit_value) { should == 25 }
        its(:total_pages) { should == 4 }
        it { should skip(0) }
      end

      context 'page 2' do
        subject { User.page 2 }
        it { should be_a Plucky::Query }
        its(:current_page) { should == 2 }
        its(:limit_value) { should == 25 }
        its(:total_pages) { should == 4 }
        it { should skip 25 }
      end

      context 'page "foobar"' do
        subject { User.page 'foobar' }
        it { should be_a Plucky::Query }
        its(:current_page) { should == 1 }
        its(:limit_value) { should == 25 }
        its(:total_pages) { should == 4 }
        it { should skip 0 }
      end

      context 'with criteria before' do
        it "should have the proper criteria source" do
          User.where(:salary => 1).page(2).criteria.source.should == {:salary => 1}
        end

        subject { User.where(:salary => 1).page 2 }
        its(:current_page) { should == 2 }
        its(:limit_value) { should == 25 }
        its(:total_pages) { should == 4 }
        it { should skip 25 }
      end

      context 'with criteria after' do
        it "should have the proper criteria source" do
          User.where(:salary => 1).page(2).criteria.source.should == {:salary => 1}
        end

        subject { User.page(2).where(:salary => 1) }
        its(:current_page) { should == 2 }
        its(:limit_value) { should == 25 }
        its(:total_pages) { should == 4 }
        it { should skip 25 }
      end
    end

    describe 'with out of range configuration' do
      context 'set to :blank' do
        subject { User.page(5) }
        # not sure how to return empty array when out of range
        #it { should == [] }
        its(:current_page) { should == 5 }
        it { should skip 100 }
      end

      context 'set to :first' do
        before do
          Kaminari.configure {|c| c.out_of_range = :first}
        end
        subject { User.page(5) }
        its(:current_page) { should == 1 }
        it { should skip 0 }
        after do
          Kaminari.configure {|c| c.out_of_range = :blank}
        end
      end

      context 'set to :last' do
        before do
          Kaminari.configure {|c| c.out_of_range = :last}
        end
        subject { User.page(5) }
        its(:current_page) { should == 4 }
        it { should skip 75 }
        after do
          Kaminari.configure {|c| c.out_of_range = :blank}
        end
      end
    end

    describe '#per' do
      subject { User.page(2).per(10) }
      it { should be_a Plucky::Query }
      its(:current_page) { should == 2 }
      its(:limit_value) { should == 10 }
      its(:total_pages) { should == 10 }
      it { should skip 10 }
    end
  end
end
