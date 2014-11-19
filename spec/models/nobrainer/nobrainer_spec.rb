require 'spec_helper'

if defined? NoBrainer
  describe Kaminari::NoBrainerCriteriaMethods do
    describe "#total_count" do
      before do
        2.times {|i| User.create(:salary => i) }
      end

      context "when the scope is cloned" do
        let(:criteria) { User.page }
        it "should reset total_count memoization" do
          criteria.total_count.should == 2
          criteria.where(:salary => 1).total_count.should == 1
        end
      end
    end
  end

  describe Kaminari::NoBrainerExtension do
    before do
      90.times do |i|
        User.create(:name => "User#{i}", :age => i)
      end
    end

    describe 'Model' do
      subject{ User }
      it { should respond_to(:page) }
      it { should respond_to(:default_per_page) }
      it { should_not respond_to(:per) }
    end

    describe 'Collection' do
      subject { User.all }
      it { should respond_to(:page) }
      it { should_not respond_to(:per) }
    end

    describe '#page' do
      context 'page 0' do
        subject { User.where(:age.gte => 60).page 0 }
        it { should be_a NoBrainer::Criteria }
        its(:current_page) { should == 1 }
        its(:prev_page) { should be_nil }
        its(:next_page) { should == 2 }
        its(:limit_value) { should == 25 }
        its(:offset_value) { should == 0 }
        its(:total_count) { should == User.where(:age.gte => 60).count }
        its(:total_pages) { should == 2 }
      end

      context 'page 1' do
        subject { User.where(:age.gte => 0).page 1 }
        it { should be_a NoBrainer::Criteria }
        its(:current_page) { should == 1 }
        its(:prev_page) { should be_nil }
        its(:next_page) { should == 2 }
        its(:limit_value) { should == 25 }
        its(:offset_value) { should == 0 }
        its(:total_count) { should == 90 }
        its(:total_pages) { should == 4 }
      end

      context 'page 2' do
        subject { User.page 2 }
        it { should be_a NoBrainer::Criteria }
        its(:current_page) { should == 2 }
        its(:prev_page) { should == 1 }
        its(:next_page) { should == 3 }
        its(:limit_value) { should == 25 }
        its(:limit_value) { should == 25 }
        its(:offset_value) { should == 25 }
        its(:total_count) { should == 90 }
        its(:total_pages) { should == 4 }
      end

      context 'page "foobar"' do
        subject { User.page 'foobar' }
        it { should be_a NoBrainer::Criteria }
        its(:current_page) { should == 1 }
        its(:prev_page) { should be_nil }
        its(:next_page) { should == 2 }
        its(:limit_value) { should == 25 }
        its(:offset_value) { should == 0 }
        its(:total_count) { should == 90 }
        its(:total_pages) { should == 4 }
      end

      context 'with criteria before' do
        subject { User.where(:age.gt => 60).page 2 }
        it { should be_a NoBrainer::Criteria }
        its(:current_page) { should == 2 }
        its(:prev_page) { should == 1 }
        its(:next_page) { should be_nil }
        its(:limit_value) { should == 25 }
        its(:offset_value) { should == 25 }
        its(:total_count) { should == User.where(:age.gt => 60).count }
        its(:total_pages) { should == 2 }
      end

      context 'with criteria after' do
        subject { User.page(2).where(:age.gt => 60) }
        it { should be_a NoBrainer::Criteria }
        its(:current_page) { should == 2 }
        its(:prev_page) { should == 1 }
        its(:next_page) { should be_nil }
        its(:limit_value) { should == 25 }
        its(:offset_value) { should == 25 }
        its(:total_count) { should == User.where(:age.gt => 60).count }
        its(:total_pages) { should == 2 }
      end
    end

    describe '#per' do
      context 'on simple query' do
        subject { User.page(2).per(20) }
        it { should be_a NoBrainer::Criteria }
        its(:current_page) { should == 2 }
        its(:prev_page) { should == 1 }
        its(:next_page) { should == 3 }
        its(:limit_value) { should == 20 }
        its(:limit_value) { should == 20 }
        its(:offset_value) { should == 20 }
        its(:total_count) { should == 90 }
        its(:total_pages) { should == 5 }
      end

      context 'on query with condition' do
        subject { User.page(5).where(:age.lte => 80).per(13) }
        its(:current_page) { should == 5 }
        its(:prev_page) { should == 4 }
        its(:next_page) { should == 6 }
        its(:limit_value) { should == 13 }
        its(:offset_value) { should == 52 }
        its(:total_count) { should == 81 }
        its(:total_pages) { should == 7 }
      end

      context 'on query with order' do
        subject { User.page(5).where(:age.lte => 80).order_by(:age => :asc).per(13) }
        it('includes user with age 52') { subject.to_a.should include(User.where(:age => 52).first) }
        it('does not include user with age 51') { subject.to_a.should_not include(User.where(:age => 51).first) }
        it('includes user with age 52') { subject.to_a.should include(User.where(:age => 64).first) }
        it('does not include user with age 51') { subject.to_a.should_not include(User.where(:age => 65).first) }
        its(:current_page) { should == 5 }
        its(:prev_page) { should == 4 }
        its(:next_page) { should == 6 }
        its(:limit_value) { should == 13 }
        its(:offset_value) { should == 52 }
        its(:total_count) { should == 81 }
        its(:total_pages) { should == 7 }
      end

      context 'on chained queries' do
        subject { User.where(:age.gte => 50).page(3).where(:age.lte => 80).per(13) }
        its(:current_page) { should == 3 }
        its(:prev_page) { should == 2 }
        its(:next_page) { should be_nil }
        its(:limit_value) { should == 13 }
        its(:offset_value) { should == 26 }
        its(:total_count) { should == 31 }
        its(:total_pages) { should == 3 }
      end

      context 'for association' do
        before do
          worker0 = User.first
          30.times { |i| Project.create(:user => worker0, :name => "Project#{i}") }
        end

        context 'on query' do
          subject { User.first.projects.page(3).where(:name => /^Project/).per(5) }
          its(:current_page) { should == 3 }
          its(:prev_page) { should == 2 }
          its(:next_page) { should == 4 }
          its(:limit_value) { should == 5 }
          its(:offset_value) { should == 10 }
          its(:total_count) { should == 30 }
          its(:total_pages) { should == 6 }
        end
      end
    end
  end
end
