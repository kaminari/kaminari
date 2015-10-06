require 'spec_helper'

if defined? Mongoid
  describe Kaminari::MongoidCriteriaMethods do
    describe "#total_count" do
      before do
        2.times {|i| User.create!(salary: i) }
      end

      context "when the scope is cloned" do
        it "should reset total_coount momoization" do
          User.page.tap(&:total_count).where(salary: 1).total_count.should == 1
        end
      end
    end
  end

  describe Kaminari::MongoidExtension do
    before(:each) do
      41.times do
        User.create!({salary: 1})
      end
    end

    describe 'max_scan', if: Mongoid::VERSION >= '3' do
      context 'less than total' do
        context 'page 1' do
          subject { User.max_scan(20).page 1 }
          it { should be_a Mongoid::Criteria }
          its(:current_page) { should == 1   }
          its(:prev_page)    { should be_nil }
          its(:next_page)    { should be_nil }
          its(:limit_value)  { should == 25  }
          its(:total_pages)  { should == 1   }
          its(:total_count)  { should == 20  }
          it { should skip(0) }
        end

        context 'page 2' do
          subject { User.max_scan(30).page 2 }
          it { should be_a Mongoid::Criteria }
          its(:current_page) { should == 2   }
          its(:prev_page)    { should == 1   }
          its(:next_page)    { should be_nil }
          its(:limit_value)  { should == 25  }
          its(:total_pages)  { should == 2   }
          its(:total_count)  { should == 30  }
          it { should skip 25 }
        end
      end

      context 'more than total' do
        context 'page 1' do
          subject { User.max_scan(60).page 1 }
          it { should be_a Mongoid::Criteria }
          its(:current_page) { should == 1   }
          its(:prev_page)    { should be_nil }
          its(:next_page)    { should == 2   }
          its(:limit_value)  { should == 25  }
          its(:total_pages)  { should == 2   }
          its(:total_count)  { should == 41  }
          it { should skip(0) }
        end

        context 'page 2' do
          subject { User.max_scan(60).page 2 }
          it { should be_a Mongoid::Criteria }
          its(:current_page) { should == 2   }
          its(:prev_page) { should == 1      }
          its(:next_page) { should be_nil    }
          its(:limit_value) { should == 25   }
          its(:total_pages) { should == 2    }
          its(:total_count)  { should == 41  }
          it { should skip 25 }
        end
      end
    end

    describe '#page' do

      context 'page 1' do
        subject { User.page 1 }
        it { should be_a Mongoid::Criteria }
        its(:current_page) { should == 1 }
        its(:prev_page) { should be_nil }
        its(:next_page) { should == 2 }
        its(:limit_value) { should == 25 }
        its(:total_pages) { should == 2 }
        it { should skip(0) }
      end

      context 'page 2' do
        subject { User.page 2 }
        it { should be_a Mongoid::Criteria }
        its(:current_page) { should == 2 }
        its(:prev_page) { should == 1 }
        its(:next_page) { should be_nil }
        its(:limit_value) { should == 25 }
        its(:total_pages) { should == 2 }
        it { should skip 25 }
      end

      context 'page "foobar"' do
        subject { User.page 'foobar' }
        it { should be_a Mongoid::Criteria }
        its(:current_page) { should == 1 }
        its(:prev_page) { should be_nil }
        its(:next_page) { should == 2 }
        its(:limit_value) { should == 25 }
        its(:total_pages) { should == 2 }
        it { should skip 0 }
      end

      shared_examples 'complete valid pagination' do
        if Mongoid::VERSION > '3.0.0'
          its(:selector) { should == {'salary' => 1} }
        else
          its(:selector) { should == {salary: 1} }
        end
        its(:current_page) { should == 2 }
        its(:prev_page) { should == 1 }
        its(:next_page) { should be_nil }
        its(:limit_value) { should == 25 }
        its(:total_pages) { should == 2 }
        it { should skip 25 }
      end

      context 'with criteria before' do
        subject { User.where(salary: 1).page 2 }
        it_should_behave_like 'complete valid pagination'
      end

      context 'with criteria after' do
        subject { User.page(2).where(salary: 1) }
        it_should_behave_like 'complete valid pagination'
      end

      context "with database:", if: Mongoid::VERSION >= '3' do
        before :all do
          15.times { User.with(database: "default_db").create!(salary: 1) }
          10.times { User.with(database: "other_db").create!(salary: 1) }
        end

        context "default_db" do
          subject { User.with(database: "default_db").order_by(:artist.asc).page(1) }
          its(:total_count) { should == 15 }
        end

        context "other_db" do
          subject { User.with(database: "other_db").order_by(:artist.asc).page(1) }
          its(:total_count) { should == 10 }
        end
      end
    end

    describe '#per' do
      subject { User.page(2).per(10) }
      it { should be_a Mongoid::Criteria }
      its(:current_page) { should == 2 }
      its(:prev_page) { should == 1 }
      its(:next_page) { should == 3 }
      its(:limit_value) { should == 10 }
      its(:total_pages) { should == 5 }
      it { should skip 10 }
    end

    describe '#page in embedded documents' do
      before do
        @mongo_developer = MongoMongoidExtensionDeveloper.new
        @mongo_developer.frameworks.new(name: "rails", language: "ruby")
        @mongo_developer.frameworks.new(name: "merb", language: "ruby")
        @mongo_developer.frameworks.new(name: "sinatra", language: "ruby")
        @mongo_developer.frameworks.new(name: "cakephp", language: "php")
        @mongo_developer.frameworks.new(name: "tornado", language: "python")
      end

      context 'page 1' do
        subject { @mongo_developer.frameworks.page(1).per(1) }
        it { should be_a Mongoid::Criteria }
        its(:total_count) { should == 5 }
        its(:limit_value) { should == 1 }
        its(:current_page) { should == 1 }
        its(:prev_page) { should be_nil }
        its(:next_page) { should == 2 }
        its(:total_pages) { should == 5 }
      end

      context 'with criteria after' do
        subject { @mongo_developer.frameworks.page(1).per(2).where(language: "ruby") }
        it { should be_a Mongoid::Criteria }
        its(:total_count) { should == 3 }
        its(:limit_value) { should == 2 }
        its(:current_page) { should == 1 }
        its(:prev_page) { should be_nil }
        its(:next_page) { should == 2 }
        its(:total_pages) { should == 2 }
      end

      context 'with criteria before' do
        subject { @mongo_developer.frameworks.where(language: "ruby").page(1).per(2) }
        it { should be_a Mongoid::Criteria }
        its(:total_count) { should == 3 }
        its(:limit_value) { should == 2 }
        its(:current_page) { should == 1 }
        its(:prev_page) { should be_nil }
        its(:next_page) { should == 2 }
        its(:total_pages) { should == 2 }
      end
    end

    describe '#paginates_per' do
      context 'when paginates_per is not defined in superclass' do
        subject { Product.all.page 1 }
        its(:limit_value) { should == 25 }
      end

      context 'when paginates_per is defined in subclass' do
        subject { Device.all.page 1 }
        its(:limit_value) { should == 100 }
      end

      context 'when paginates_per is defined in subclass of subclass' do
        subject { Android.all.page 1 }
        its(:limit_value) { should == 200 }
      end
    end
  end
end
