require 'spec_helper'

describe Kaminari::PaginatableArray do
  it { should have(0).items }

  context 'specifying limit and offset when initializing' do
    subject { Kaminari::PaginatableArray.new((1..100).to_a, :limit => 10, :offset => 20) }
    its(:current_page) { should == 3 }
  end

  let(:array) { Kaminari::PaginatableArray.new((1..100).to_a) }
  describe '#page' do
    shared_examples_for 'the first page of array' do
      it { should have(25).users }
      its(:current_page) { should == 1 }
      its(:first) { should == 1 }
    end

    shared_examples_for 'blank array page' do
      it { should have(0).items }
    end

    context 'page 1' do
      subject { array.page 1 }
      it_should_behave_like 'the first page of array'
    end

    context 'page 2' do
      subject { array.page 2 }
      it { should have(25).users }
      its(:current_page) { should == 2 }
      its(:first) { should == 26 }
    end

    context 'page without an argument' do
      subject { array.page }
      it_should_behave_like 'the first page of array'
    end

    context 'page < 1' do
      subject { array.page 0 }
      it_should_behave_like 'the first page of array'
    end

    context 'page > max page' do
      subject { array.page 5 }
      it_should_behave_like 'blank array page'
    end
  end

  describe '#per' do
    context 'page 1 per 5' do
      subject { array.page(1).per(5) }
      it { should have(5).users }
      its(:first) { should == 1 }
    end

    context "page 1 per 0" do
      subject { array.page(1).per(0) }
      it { should have(0).users }
    end
  end

  describe '#total_pages' do
    context 'per 25 (default)' do
      subject { array.page }
      its(:total_pages) { should == 4 }
    end

    context 'per 7' do
      subject { array.page(2).per(7) }
      its(:total_pages) { should == 15 }
    end

    context 'per 65536' do
      subject { array.page(50).per(65536) }
      its(:total_pages) { should == 1 }
    end

    context 'per 0' do
      subject { array.page(50).per(0) }
      it "raises Kaminari::ZeroPerPageOperation" do
        expect { subject.total_pages }.to raise_error(Kaminari::ZeroPerPageOperation)
      end
    end

    context 'per -1 (using default)' do
      subject { array.page(5).per(-1) }
      its(:total_pages) { should == 4 }
    end

    context 'per "String value that can not be converted into Number" (using default)' do
      subject { array.page(5).per('aho') }
      its(:total_pages) { should == 4 }
    end

    context 'per 25, padding 25' do
      subject { array.page(1).padding(25) }
      its(:total_pages) { should == 3 }
    end
  end

  describe '#current_page' do
    context 'any page, per 0' do
      subject { array.page.per(0) }
      it "raises Kaminari::ZeroPerPageOperation" do
        expect { subject.current_page }.to raise_error(Kaminari::ZeroPerPageOperation)
      end
    end

    context 'page 1' do
      subject { array.page }
      its(:current_page) { should == 1 }
    end

    context 'page 2' do
      subject { array.page(2).per 3 }
      its(:current_page) { should == 2 }
    end
  end

  describe '#next_page' do
    context 'page 1' do
      subject { array.page }
      its(:next_page) { should == 2 }
    end

    context 'page 5' do
      subject { array.page 5 }
      its(:next_page) { should be_nil }
    end
  end

  describe '#prev_page' do
    context 'page 1' do
      subject { array.page }
      its(:prev_page) { should be_nil }
    end

    context 'page 3' do
      subject { array.page 3 }
      its(:prev_page) { should == 2 }
    end

    context 'page 5' do
      subject { array.page 5 }
      its(:prev_page) { should be_nil }
    end
  end

  describe '#count' do
    context 'page 1' do
      subject { array.page }
      its(:count) { should == 25 }
    end

    context 'page 2' do
      subject { array.page 2 }
      its(:count) { should == 25 }
    end
  end

  context 'when setting total count explicitly' do
    context "array 1..10, page 5, per 10, total_count 9999" do
      subject { Kaminari::PaginatableArray.new((1..10).to_a, :total_count => 9999).page(5).per(10) }

      it { should have(10).items }
      its(:first) { should == 1 }
      its(:current_page) { should == 5 }
      its(:total_count) { should == 9999 }
    end

    context "array 1..10, page 5, per 5, total_count 9999" do
      subject { Kaminari::PaginatableArray.new((1..10).to_a, :total_count => 9999).page(5).per(5) }

      it { should have(5).items }
      its(:first) { should == 1 }
      its(:current_page) { should == 5 }
      its(:total_count) { should == 9999 }
    end

    context "array 1..15, page 1, per 10, total_count 15" do
      subject { Kaminari.paginate_array((1..15).to_a, :total_count => 15).page(1).per(10) }

      it { should have(10).items }
      its(:first) { should == 1 }
      its(:current_page) { should == 1 }
      its(:total_count) { should == 15 }
    end

    context "array 1..25, page 2, per 10, total_count 15" do
      subject { Kaminari.paginate_array((1..25).to_a, :total_count => 15).page(2).per(10) }

      it { should have(5).items }
      its(:first) { should == 11 }
      its(:current_page) { should == 2 }
      its(:total_count) { should == 15 }
    end
  end
end
