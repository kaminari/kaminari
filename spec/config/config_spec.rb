require 'spec_helper'

describe Kaminari::Configuration do
  subject { Kaminari.config }
  describe 'default_per_page' do
    context 'by default' do
      describe '#default_per_page' do
        subject { super().default_per_page }
        it { is_expected.to eq(25) }
      end
    end
    context 'configured via config block' do
      before do
        Kaminari.configure {|c| c.default_per_page = 17}
      end

      describe '#default_per_page' do
        subject { super().default_per_page }
        it { is_expected.to eq(17) }
      end
      after do
        Kaminari.configure {|c| c.default_per_page = 25}
      end
    end
  end

  describe 'max_per_page' do
    context 'by default' do
      describe '#max_per_page' do
        subject { super().max_per_page }
        it { is_expected.to eq(nil) }
      end
    end
    context 'configure via config block' do
      before do
        Kaminari.configure {|c| c.max_per_page = 100}
      end

      describe '#max_per_page' do
        subject { super().max_per_page }
        it { is_expected.to eq(100) }
      end
      after do
        Kaminari.configure {|c| c.max_per_page = nil}
      end
    end
  end

  describe 'window' do
    context 'by default' do
      describe '#window' do
        subject { super().window }
        it { is_expected.to eq(4) }
      end
    end
  end

  describe 'outer_window' do
    context 'by default' do
      describe '#outer_window' do
        subject { super().outer_window }
        it { is_expected.to eq(0) }
      end
    end
  end

  describe 'left' do
    context 'by default' do
      describe '#left' do
        subject { super().left }
        it { is_expected.to eq(0) }
      end
    end
  end

  describe 'right' do
    context 'by default' do
      describe '#right' do
        subject { super().right }
        it { is_expected.to eq(0) }
      end
    end
  end

  describe 'param_name' do
    context 'by default' do
      describe '#param_name' do
        subject { super().param_name }
        it { is_expected.to eq(:page) }
      end
    end

    context 'configured via config block' do
      before do
        Kaminari.configure {|c| c.param_name = lambda { :test } }
      end

      describe '#param_name' do
        subject { super().param_name }
        it { is_expected.to eq(:test) }
      end

      after do
        Kaminari.configure {|c| c.param_name = :page }
      end
    end
  end

  describe 'max_pages' do
    context 'by default' do
      describe '#max_pages' do
        subject { super().max_pages }
        it { is_expected.to eq(nil) }
      end
    end
    context 'configure via config block' do
      before do
        Kaminari.configure {|c| c.max_pages = 5}
      end

      describe '#max_pages' do
        subject { super().max_pages }
        it { is_expected.to eq(5) }
      end
      after do
        Kaminari.configure {|c| c.max_pages = nil}
      end
    end
  end
end
