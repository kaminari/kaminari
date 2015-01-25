require 'spec_helper'

if defined? Mongoid
  describe Kaminari::MongoidCriteriaMethods, :type => :model do
    describe "#total_count" do
      before do
        2.times {|i| User.create!(:salary => i) }
      end

      context "when the scope is cloned" do
        it "should reset total_coount momoization" do
          expect(User.page.tap(&:total_count).where(:salary => 1).total_count).to eq(1)
        end
      end
    end
  end

  describe Kaminari::MongoidExtension, :type => :model do
    before(:each) do
      41.times do
        User.create!({:salary => 1})
      end
    end

    describe 'max_scan', :if => Mongoid::VERSION >= '3' do
      context 'less than total' do
        context 'page 1' do
          subject { User.max_scan(20).page 1 }
          it { is_expected.to be_a Mongoid::Criteria }

          describe '#current_page' do
            subject { super().current_page }
            it { is_expected.to eq(1)   }
          end

          describe '#prev_page' do
            subject { super().prev_page }
            it { is_expected.to be_nil }
          end

          describe '#next_page' do
            subject { super().next_page }
            it { is_expected.to be_nil }
          end

          describe '#limit_value' do
            subject { super().limit_value }
            it { is_expected.to eq(25)  }
          end

          describe '#total_pages' do
            subject { super().total_pages }
            it { is_expected.to eq(1)   }
          end

          describe '#total_count' do
            subject { super().total_count }
            it { is_expected.to eq(20)  }
          end
          it { is_expected.to skip(0) }
        end

        context 'page 2' do
          subject { User.max_scan(30).page 2 }
          it { is_expected.to be_a Mongoid::Criteria }

          describe '#current_page' do
            subject { super().current_page }
            it { is_expected.to eq(2)   }
          end

          describe '#prev_page' do
            subject { super().prev_page }
            it { is_expected.to eq(1)   }
          end

          describe '#next_page' do
            subject { super().next_page }
            it { is_expected.to be_nil }
          end

          describe '#limit_value' do
            subject { super().limit_value }
            it { is_expected.to eq(25)  }
          end

          describe '#total_pages' do
            subject { super().total_pages }
            it { is_expected.to eq(2)   }
          end

          describe '#total_count' do
            subject { super().total_count }
            it { is_expected.to eq(30)  }
          end
          it { is_expected.to skip 25 }
        end
      end

      context 'more than total' do
        context 'page 1' do
          subject { User.max_scan(60).page 1 }
          it { is_expected.to be_a Mongoid::Criteria }

          describe '#current_page' do
            subject { super().current_page }
            it { is_expected.to eq(1)   }
          end

          describe '#prev_page' do
            subject { super().prev_page }
            it { is_expected.to be_nil }
          end

          describe '#next_page' do
            subject { super().next_page }
            it { is_expected.to eq(2)   }
          end

          describe '#limit_value' do
            subject { super().limit_value }
            it { is_expected.to eq(25)  }
          end

          describe '#total_pages' do
            subject { super().total_pages }
            it { is_expected.to eq(2)   }
          end

          describe '#total_count' do
            subject { super().total_count }
            it { is_expected.to eq(41)  }
          end
          it { is_expected.to skip(0) }
        end

        context 'page 2' do
          subject { User.max_scan(60).page 2 }
          it { is_expected.to be_a Mongoid::Criteria }

          describe '#current_page' do
            subject { super().current_page }
            it { is_expected.to eq(2)   }
          end

          describe '#prev_page' do
            subject { super().prev_page }
            it { is_expected.to eq(1)      }
          end

          describe '#next_page' do
            subject { super().next_page }
            it { is_expected.to be_nil    }
          end

          describe '#limit_value' do
            subject { super().limit_value }
            it { is_expected.to eq(25)   }
          end

          describe '#total_pages' do
            subject { super().total_pages }
            it { is_expected.to eq(2)    }
          end

          describe '#total_count' do
            subject { super().total_count }
            it { is_expected.to eq(41)  }
          end
          it { is_expected.to skip 25 }
        end
      end
    end

    describe '#page' do

      context 'page 1' do
        subject { User.page 1 }
        it { is_expected.to be_a Mongoid::Criteria }

        describe '#current_page' do
          subject { super().current_page }
          it { is_expected.to eq(1) }
        end

        describe '#prev_page' do
          subject { super().prev_page }
          it { is_expected.to be_nil }
        end

        describe '#next_page' do
          subject { super().next_page }
          it { is_expected.to eq(2) }
        end

        describe '#limit_value' do
          subject { super().limit_value }
          it { is_expected.to eq(25) }
        end

        describe '#total_pages' do
          subject { super().total_pages }
          it { is_expected.to eq(2) }
        end
        it { is_expected.to skip(0) }
      end

      context 'page 2' do
        subject { User.page 2 }
        it { is_expected.to be_a Mongoid::Criteria }

        describe '#current_page' do
          subject { super().current_page }
          it { is_expected.to eq(2) }
        end

        describe '#prev_page' do
          subject { super().prev_page }
          it { is_expected.to eq(1) }
        end

        describe '#next_page' do
          subject { super().next_page }
          it { is_expected.to be_nil }
        end

        describe '#limit_value' do
          subject { super().limit_value }
          it { is_expected.to eq(25) }
        end

        describe '#total_pages' do
          subject { super().total_pages }
          it { is_expected.to eq(2) }
        end
        it { is_expected.to skip 25 }
      end

      context 'page "foobar"' do
        subject { User.page 'foobar' }
        it { is_expected.to be_a Mongoid::Criteria }

        describe '#current_page' do
          subject { super().current_page }
          it { is_expected.to eq(1) }
        end

        describe '#prev_page' do
          subject { super().prev_page }
          it { is_expected.to be_nil }
        end

        describe '#next_page' do
          subject { super().next_page }
          it { is_expected.to eq(2) }
        end

        describe '#limit_value' do
          subject { super().limit_value }
          it { is_expected.to eq(25) }
        end

        describe '#total_pages' do
          subject { super().total_pages }
          it { is_expected.to eq(2) }
        end
        it { is_expected.to skip 0 }
      end

      shared_examples 'complete valid pagination' do
        if Mongoid::VERSION > '3.0.0'
          describe '#selector' do
            subject { super().selector }
            it { is_expected.to eq({'salary' => 1}) }
          end
        else
          describe '#selector' do
            subject { super().selector }
            it { is_expected.to eq({:salary => 1}) }
          end
        end

        describe '#current_page' do
          subject { super().current_page }
          it { is_expected.to eq(2) }
        end

        describe '#prev_page' do
          subject { super().prev_page }
          it { is_expected.to eq(1) }
        end

        describe '#next_page' do
          subject { super().next_page }
          it { is_expected.to be_nil }
        end

        describe '#limit_value' do
          subject { super().limit_value }
          it { is_expected.to eq(25) }
        end

        describe '#total_pages' do
          subject { super().total_pages }
          it { is_expected.to eq(2) }
        end
        it { is_expected.to skip 25 }
      end

      context 'with criteria before' do
        subject { User.where(:salary => 1).page 2 }
        it_should_behave_like 'complete valid pagination'
      end

      context 'with criteria after' do
        subject { User.page(2).where(:salary => 1) }
        it_should_behave_like 'complete valid pagination'
      end

      context "with database:", :if => Mongoid::VERSION >= '3' do
        before :all do
          15.times { User.with(:database => "default_db").create!(:salary => 1) }
          10.times { User.with(:database => "other_db").create!(:salary => 1) }
        end

        context "default_db" do
          subject { User.with(:database => "default_db").order_by(:artist.asc).page(1) }

          describe '#total_count' do
            subject { super().total_count }
            it { is_expected.to eq(15) }
          end
        end

        context "other_db" do
          subject { User.with(:database => "other_db").order_by(:artist.asc).page(1) }

          describe '#total_count' do
            subject { super().total_count }
            it { is_expected.to eq(10) }
          end
        end
      end
    end

    describe '#per' do
      subject { User.page(2).per(10) }
      it { is_expected.to be_a Mongoid::Criteria }

      describe '#current_page' do
        subject { super().current_page }
        it { is_expected.to eq(2) }
      end

      describe '#prev_page' do
        subject { super().prev_page }
        it { is_expected.to eq(1) }
      end

      describe '#next_page' do
        subject { super().next_page }
        it { is_expected.to eq(3) }
      end

      describe '#limit_value' do
        subject { super().limit_value }
        it { is_expected.to eq(10) }
      end

      describe '#total_pages' do
        subject { super().total_pages }
        it { is_expected.to eq(5) }
      end
      it { is_expected.to skip 10 }
    end

    describe '#page in embedded documents' do
      before do
        @mongo_developer = MongoMongoidExtensionDeveloper.new
        @mongo_developer.frameworks.new(:name => "rails", :language => "ruby")
        @mongo_developer.frameworks.new(:name => "merb", :language => "ruby")
        @mongo_developer.frameworks.new(:name => "sinatra", :language => "ruby")
        @mongo_developer.frameworks.new(:name => "cakephp", :language => "php")
        @mongo_developer.frameworks.new(:name => "tornado", :language => "python")
      end

      context 'page 1' do
        subject { @mongo_developer.frameworks.page(1).per(1) }
        it { is_expected.to be_a Mongoid::Criteria }

        describe '#total_count' do
          subject { super().total_count }
          it { is_expected.to eq(5) }
        end

        describe '#limit_value' do
          subject { super().limit_value }
          it { is_expected.to eq(1) }
        end

        describe '#current_page' do
          subject { super().current_page }
          it { is_expected.to eq(1) }
        end

        describe '#prev_page' do
          subject { super().prev_page }
          it { is_expected.to be_nil }
        end

        describe '#next_page' do
          subject { super().next_page }
          it { is_expected.to eq(2) }
        end

        describe '#total_pages' do
          subject { super().total_pages }
          it { is_expected.to eq(5) }
        end
      end

      context 'with criteria after' do
        subject { @mongo_developer.frameworks.page(1).per(2).where(:language => "ruby") }
        it { is_expected.to be_a Mongoid::Criteria }

        describe '#total_count' do
          subject { super().total_count }
          it { is_expected.to eq(3) }
        end

        describe '#limit_value' do
          subject { super().limit_value }
          it { is_expected.to eq(2) }
        end

        describe '#current_page' do
          subject { super().current_page }
          it { is_expected.to eq(1) }
        end

        describe '#prev_page' do
          subject { super().prev_page }
          it { is_expected.to be_nil }
        end

        describe '#next_page' do
          subject { super().next_page }
          it { is_expected.to eq(2) }
        end

        describe '#total_pages' do
          subject { super().total_pages }
          it { is_expected.to eq(2) }
        end
      end

      context 'with criteria before' do
        subject { @mongo_developer.frameworks.where(:language => "ruby").page(1).per(2) }
        it { is_expected.to be_a Mongoid::Criteria }

        describe '#total_count' do
          subject { super().total_count }
          it { is_expected.to eq(3) }
        end

        describe '#limit_value' do
          subject { super().limit_value }
          it { is_expected.to eq(2) }
        end

        describe '#current_page' do
          subject { super().current_page }
          it { is_expected.to eq(1) }
        end

        describe '#prev_page' do
          subject { super().prev_page }
          it { is_expected.to be_nil }
        end

        describe '#next_page' do
          subject { super().next_page }
          it { is_expected.to eq(2) }
        end

        describe '#total_pages' do
          subject { super().total_pages }
          it { is_expected.to eq(2) }
        end
      end
    end

    describe '#paginates_per' do
      context 'when paginates_per is not defined in superclass' do
        subject { Product.all.page 1 }

        describe '#limit_value' do
          subject { super().limit_value }
          it { is_expected.to eq(25) }
        end
      end

      context 'when paginates_per is defined in subclass' do
        subject { Device.all.page 1 }

        describe '#limit_value' do
          subject { super().limit_value }
          it { is_expected.to eq(100) }
        end
      end

      context 'when paginates_per is defined in subclass of subclass' do
        subject { Android.all.page 1 }
        its(:limit_value) { should == 200 }
      end
    end
  end
end
