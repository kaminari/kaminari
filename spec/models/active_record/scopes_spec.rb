require 'spec_helper'

if defined? ActiveRecord

  describe Kaminari::ActiveRecordModelExtension, :type => :model do
    before do
      Kaminari.configure do |config|
        config.page_method_name = :per_page_kaminari
      end
      class Comment < ActiveRecord::Base; end
    end

    subject { Comment }
    it { is_expected.to respond_to(:per_page_kaminari) }
    it { is_expected.not_to respond_to(:page) }

    after do
      Kaminari.configure do |config|
        config.page_method_name = :page
      end
    end
  end

  shared_examples_for 'the first page' do
    it 'has 25 users' do
      expect(subject.size).to eq(25)
    end

    describe '#first' do
      subject { super().first }
      describe '#name' do
        subject { super().name }
        it { is_expected.to eq('user001') }
      end
    end
  end

  shared_examples_for 'blank page' do
    it 'has no users' do
      expect(subject.size).to eq(0)
    end
  end

  describe Kaminari::ActiveRecordExtension, :type => :model do
    before do
      1.upto(100) {|i| User.create! :name => "user#{'%03d' % i}", :age => (i / 10)}
      1.upto(100) {|i| GemDefinedModel.create! :name => "user#{'%03d' % i}", :age => (i / 10)}
      1.upto(100) {|i| Device.create! :name => "user#{'%03d' % i}", :age => (i / 10)}
    end

    [User, Admin, GemDefinedModel, Device].each do |model_class|
      context "for #{model_class}" do
        describe '#page' do
          context 'page 1' do
            subject { model_class.page 1 }
            it_should_behave_like 'the first page'
          end

          context 'page 2' do
            subject { model_class.page 2 }
            it 'has 25 users' do
              expect(subject.size).to eq(25)
            end

            describe '#first' do
              subject { super().first }
              describe '#name' do
                subject { super().name }
                it { is_expected.to eq('user026') }
              end
            end
          end

          context 'page without an argument' do
            subject { model_class.page }
            it_should_behave_like 'the first page'
          end

          context 'page < 1' do
            subject { model_class.page 0 }
            it_should_behave_like 'the first page'
          end

          context 'page > max page' do
            subject { model_class.page 5 }
            it_should_behave_like 'blank page'
          end

          describe 'ensure #order_values is preserved' do
            subject { model_class.order('id').page 1 }

            describe '#order_values' do
              subject { super().order_values }
              describe '#uniq' do
                subject { super().uniq }
                it { is_expected.to eq(['id']) }
              end
            end
          end
        end

        describe '#per' do
          context 'page 1 per 5' do
            subject { model_class.page(1).per(5) }
            it 'has 5 users' do
              expect(subject.size).to eq(5)
            end

            describe '#first' do
              subject { super().first }
              describe '#name' do
                subject { super().name }
                it { is_expected.to eq('user001') }
              end
            end
          end

          context "page 1 per nil (using default)" do
            subject { model_class.page(1).per(nil) }
            it 'has model_class.default_per_page users' do
              expect(subject.size).to eq(model_class.default_per_page)
            end
          end

          context "page 1 per 0" do
            subject { model_class.page(1).per(0) }
            it 'has no users' do
              expect(subject.size).to eq(0)
            end
          end
        end

        describe '#padding' do
          context 'page 1 per 5 padding 1' do
            subject { model_class.page(1).per(5).padding(1) }
            it 'has 5 users' do
              expect(subject.size).to eq(5)
            end

            describe '#first' do
              subject { super().first }
              describe '#name' do
                subject { super().name }
                it { is_expected.to eq('user002') }
              end
            end
          end

          context 'page 19 per 5 padding 5' do
            subject { model_class.page(19).per(5).padding(5) }

            describe '#current_page' do
              subject { super().current_page }
              it { is_expected.to eq(19) }
            end

            describe '#total_pages' do
              subject { super().total_pages }
              it { is_expected.to eq(19) }
            end
          end
        end

        describe '#total_pages' do
          context 'per 25 (default)' do
            subject { model_class.page }

            describe '#total_pages' do
              subject { super().total_pages }
              it { is_expected.to eq(4) }
            end
          end

          context 'per 7' do
            subject { model_class.page(2).per(7) }

            describe '#total_pages' do
              subject { super().total_pages }
              it { is_expected.to eq(15) }
            end
          end

          context 'per 65536' do
            subject { model_class.page(50).per(65536) }

            describe '#total_pages' do
              subject { super().total_pages }
              it { is_expected.to eq(1) }
            end
          end

          context 'per 0' do
            subject { model_class.page(50).per(0) }
            it "raises Kaminari::ZeroPerPageOperation" do
              expect { subject.total_pages }.to raise_error(Kaminari::ZeroPerPageOperation)
            end
          end

          context 'per -1 (using default)' do
            subject { model_class.page(5).per(-1) }

            describe '#total_pages' do
              subject { super().total_pages }
              it { is_expected.to eq(4) }
            end
          end

          context 'per "String value that can not be converted into Number" (using default)' do
            subject { model_class.page(5).per('aho') }

            describe '#total_pages' do
              subject { super().total_pages }
              it { is_expected.to eq(4) }
            end
          end

          context 'with max_pages < total pages count from database' do
            before { model_class.max_pages_per 3 }
            subject { model_class.page }

            describe '#total_pages' do
              subject { super().total_pages }
              it { is_expected.to eq(3) }
            end
            after { model_class.max_pages_per nil }
          end

          context 'with max_pages > total pages count from database' do
            before { model_class.max_pages_per 11 }
            subject { model_class.page }

            describe '#total_pages' do
              subject { super().total_pages }
              it { is_expected.to eq(4) }
            end
            after { model_class.max_pages_per nil }
          end

          context 'with max_pages is nil' do
            before { model_class.max_pages_per nil }
            subject { model_class.page }

            describe '#total_pages' do
              subject { super().total_pages }
              it { is_expected.to eq(4) }
            end
          end

          context "with per(nil) using default" do
            subject { model_class.page.per(nil) }

            describe '#total_pages' do
              subject { super().total_pages }
              it { is_expected.to eq(4) }
            end
          end
        end

        describe '#current_page' do
          context 'any page, per 0' do
            subject { model_class.page.per(0) }
            it "raises Kaminari::ZeroPerPageOperation" do
              expect { subject.current_page }.to raise_error(Kaminari::ZeroPerPageOperation)
            end
          end

          context 'page 1' do
            subject { model_class.page }

            describe '#current_page' do
              subject { super().current_page }
              it { is_expected.to eq(1) }
            end
          end

          context 'page 2' do
            subject { model_class.page(2).per 3 }

            describe '#current_page' do
              subject { super().current_page }
              it { is_expected.to eq(2) }
            end
          end
        end

        describe '#next_page' do
          context 'page 1' do
            subject { model_class.page }

            describe '#next_page' do
              subject { super().next_page }
              it { is_expected.to eq(2) }
            end
          end

          context 'page 5' do
            subject { model_class.page(5) }

            describe '#next_page' do
              subject { super().next_page }
              it { is_expected.to be_nil }
            end
          end
        end

        describe '#prev_page' do
          context 'page 1' do
            subject { model_class.page }

            describe '#prev_page' do
              subject { super().prev_page }
              it { is_expected.to be_nil }
            end
          end

          context 'page 3' do
            subject { model_class.page(3) }

            describe '#prev_page' do
              subject { super().prev_page }
              it { is_expected.to eq(2) }
            end
          end

          context 'page 5' do
            subject { model_class.page(5) }

            describe '#prev_page' do
              subject { super().prev_page }
              it { is_expected.to be_nil }
            end
          end
        end

        describe '#first_page?' do
          context 'on first page' do
            subject { model_class.page(1).per(10) }

            describe '#first_page?' do
              subject { super().first_page? }
              it { is_expected.to eq(true) }
            end
          end

          context 'not on first page' do
            subject { model_class.page(5).per(10) }

            describe '#first_page?' do
              subject { super().first_page? }
              it { is_expected.to eq(false) }
            end
          end
        end

        describe '#last_page?' do
          context 'on last page' do
            subject { model_class.page(10).per(10) }

            describe '#last_page?' do
              subject { super().last_page? }
              it { is_expected.to eq(true) }
            end
          end

          context 'within range' do
            subject { model_class.page(1).per(10) }

            describe '#last_page?' do
              subject { super().last_page? }
              it { is_expected.to eq(false) }
            end
          end

          context 'out of range' do
            subject { model_class.page(11).per(10) }

            describe '#last_page?' do
              subject { super().last_page? }
              it { is_expected.to eq(false) }
            end
          end
        end

        describe '#out_of_range?' do
          context 'on last page' do
            subject { model_class.page(10).per(10) }

            describe '#out_of_range?' do
              subject { super().out_of_range? }
              it { is_expected.to eq(false) }
            end
          end

          context 'within range' do
            subject { model_class.page(1).per(10) }

            describe '#out_of_range?' do
              subject { super().out_of_range? }
              it { is_expected.to eq(false) }
            end
          end

          context 'out of range' do
            subject { model_class.page(11).per(10) }

            describe '#out_of_range?' do
              subject { super().out_of_range? }
              it { is_expected.to eq(true) }
            end
          end
        end

        describe '#count' do
          context 'page 1' do
            subject { model_class.page }

            describe '#count' do
              subject { super().count }
              it { is_expected.to eq(25) }
            end
          end

          context 'page 2' do
            subject { model_class.page 2 }

            describe '#count' do
              subject { super().count }
              it { is_expected.to eq(25) }
            end
          end
        end

        context 'chained with .group' do
          subject { model_class.group('age').page(2).per 5 }
          # 0..10

          describe '#total_count' do
            subject { super().total_count }
            it { is_expected.to eq(11) }
          end

          describe '#total_pages' do
            subject { super().total_pages }
            it { is_expected.to eq(3) }
          end
        end

        context 'activerecord descendants' do
          subject { ActiveRecord::Base.descendants }

          describe '#length' do
            subject { super().length }
            it { is_expected.not_to eq(0) }
          end
        end
      end
    end
  end
end
