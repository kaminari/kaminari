require 'spec_helper'

describe Kaminari::PaginatableArray, :type => :model do
  it 'has no items' do
    expect(subject.size).to eq(0)
  end

  context 'specifying limit and offset when initializing' do
    subject { Kaminari::PaginatableArray.new((1..100).to_a, :limit => 10, :offset => 20) }

    describe '#current_page' do
      subject { super().current_page }
      it { is_expected.to eq(3) }
    end
  end

  let(:array) { Kaminari::PaginatableArray.new((1..100).to_a) }
  describe '#page' do
    shared_examples_for 'the first page of array' do
      it 'has 25 users' do
        expect(subject.size).to eq(25)
      end

      describe '#current_page' do
        subject { super().current_page }
        it { is_expected.to eq(1) }
      end

      describe '#first' do
        subject { super().first }
        it { is_expected.to eq(1) }
      end
    end

    shared_examples_for 'blank array page' do
      it 'has no items' do
        expect(subject.size).to eq(0)
      end
    end

    context 'page 1' do
      subject { array.page 1 }
      it_should_behave_like 'the first page of array'
    end

    context 'page 2' do
      subject { array.page 2 }
      it 'has 25 users' do
        expect(subject.size).to eq(25)
      end

      describe '#current_page' do
        subject { super().current_page }
        it { is_expected.to eq(2) }
      end

      describe '#first' do
        subject { super().first }
        it { is_expected.to eq(26) }
      end
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
      it 'has 5 users' do
        expect(subject.size).to eq(5)
      end

      describe '#first' do
        subject { super().first }
        it { is_expected.to eq(1) }
      end
    end

    context "page 1 per 0" do
      subject { array.page(1).per(0) }
      it 'has no users' do
        expect(subject.size).to eq(0)
      end
    end
  end

  describe '#total_pages' do
    context 'per 25 (default)' do
      subject { array.page }

      describe '#total_pages' do
        subject { super().total_pages }
        it { is_expected.to eq(4) }
      end
    end

    context 'per 7' do
      subject { array.page(2).per(7) }

      describe '#total_pages' do
        subject { super().total_pages }
        it { is_expected.to eq(15) }
      end
    end

    context 'per 65536' do
      subject { array.page(50).per(65536) }

      describe '#total_pages' do
        subject { super().total_pages }
        it { is_expected.to eq(1) }
      end
    end

    context 'per 0' do
      subject { array.page(50).per(0) }
      it "raises Kaminari::ZeroPerPageOperation" do
        expect { subject.total_pages }.to raise_error(Kaminari::ZeroPerPageOperation)
      end
    end

    context 'per -1 (using default)' do
      subject { array.page(5).per(-1) }

      describe '#total_pages' do
        subject { super().total_pages }
        it { is_expected.to eq(4) }
      end
    end

    context 'per "String value that can not be converted into Number" (using default)' do
      subject { array.page(5).per('aho') }

      describe '#total_pages' do
        subject { super().total_pages }
        it { is_expected.to eq(4) }
      end
    end

    context 'per 25, padding 25' do
      subject { array.page(1).padding(25) }

      describe '#total_pages' do
        subject { super().total_pages }
        it { is_expected.to eq(3) }
      end
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

      describe '#current_page' do
        subject { super().current_page }
        it { is_expected.to eq(1) }
      end
    end

    context 'page 2' do
      subject { array.page(2).per 3 }

      describe '#current_page' do
        subject { super().current_page }
        it { is_expected.to eq(2) }
      end
    end
  end

  describe '#next_page' do
    context 'page 1' do
      subject { array.page }

      describe '#next_page' do
        subject { super().next_page }
        it { is_expected.to eq(2) }
      end
    end

    context 'page 5' do
      subject { array.page 5 }

      describe '#next_page' do
        subject { super().next_page }
        it { is_expected.to be_nil }
      end
    end
  end

  describe '#prev_page' do
    context 'page 1' do
      subject { array.page }

      describe '#prev_page' do
        subject { super().prev_page }
        it { is_expected.to be_nil }
      end
    end

    context 'page 3' do
      subject { array.page 3 }

      describe '#prev_page' do
        subject { super().prev_page }
        it { is_expected.to eq(2) }
      end
    end

    context 'page 5' do
      subject { array.page 5 }

      describe '#prev_page' do
        subject { super().prev_page }
        it { is_expected.to be_nil }
      end
    end
  end

  describe '#count' do
    context 'page 1' do
      subject { array.page }

      describe '#count' do
        subject { super().count }
        it { is_expected.to eq(25) }
      end
    end

    context 'page 2' do
      subject { array.page 2 }

      describe '#count' do
        subject { super().count }
        it { is_expected.to eq(25) }
      end
    end
  end

  context 'when setting total count explicitly' do
    context "array 1..10, page 5, per 10, total_count 9999" do
      subject { Kaminari::PaginatableArray.new((1..10).to_a, :total_count => 9999).page(5).per(10) }

      it 'has 10 items' do
        expect(subject.size).to eq(10)
      end

      describe '#first' do
        subject { super().first }
        it { is_expected.to eq(1) }
      end

      describe '#current_page' do
        subject { super().current_page }
        it { is_expected.to eq(5) }
      end

      describe '#total_count' do
        subject { super().total_count }
        it { is_expected.to eq(9999) }
      end
    end

    context "array 1..15, page 1, per 10, total_count 15" do
      subject { Kaminari.paginate_array((1..15).to_a, :total_count => 15).page(1).per(10) }

      it 'has 10 items' do
        expect(subject.size).to eq(10)
      end

      describe '#first' do
        subject { super().first }
        it { is_expected.to eq(1) }
      end

      describe '#current_page' do
        subject { super().current_page }
        it { is_expected.to eq(1) }
      end

      describe '#total_count' do
        subject { super().total_count }
        it { is_expected.to eq(15) }
      end
    end

    context "array 1..25, page 2, per 10, total_count 15" do
      subject { Kaminari.paginate_array((1..25).to_a, :total_count => 15).page(2).per(10) }

      it 'has 5 items' do
        expect(subject.size).to eq(5)
      end

      describe '#first' do
        subject { super().first }
        it { is_expected.to eq(11) }
      end

      describe '#current_page' do
        subject { super().current_page }
        it { is_expected.to eq(2) }
      end

      describe '#total_count' do
        subject { super().total_count }
        it { is_expected.to eq(15) }
      end
    end
  end
end
