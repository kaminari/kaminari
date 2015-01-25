require 'spec_helper'

describe "configuration methods", :type => :model do
  let(:model){ User }

  describe "#default_per_page" do
    if defined? ActiveRecord
      describe 'AR::Base' do
        subject { ActiveRecord::Base }
        it { is_expected.not_to respond_to :paginates_per }
      end
    end

    subject { model.page(1) }

    context "by default" do
      describe '#limit_value' do
        subject { super().limit_value }
        it { is_expected.to eq(25) }
      end
    end

    context "when configuring both on global and model-level" do
      before do
        Kaminari.configure {|c| c.default_per_page = 50 }
        model.paginates_per 100
      end

      describe '#limit_value' do
        subject { super().limit_value }
        it { is_expected.to eq(100) }
      end
    end

    context "when configuring multiple times" do
      before do
        Kaminari.configure {|c| c.default_per_page = 10 }
        Kaminari.configure {|c| c.default_per_page = 20 }
      end

      describe '#limit_value' do
        subject { super().limit_value }
        it { is_expected.to eq(20) }
      end
    end

    after do
      Kaminari.configure {|c| c.default_per_page = 25 }
      model.paginates_per nil
    end
  end

  describe "#max_per_page" do
    if defined? ActiveRecord
      describe 'AR::Base' do
        subject { ActiveRecord::Base }
        it { is_expected.not_to respond_to :max_pages_per }
      end
    end

    subject { model.page(1).per(1000) }

    context "by default" do
      describe '#limit_value' do
        subject { super().limit_value }
        it { is_expected.to eq(1000) }
      end
    end

    context "when configuring both on global and model-level" do
      before do
        Kaminari.configure {|c| c.max_per_page = 50 }
        model.max_paginates_per 100
      end

      describe '#limit_value' do
        subject { super().limit_value }
        it { is_expected.to eq(100) }
      end
    end

    context "when configuring multiple times" do
      before do
        Kaminari.configure {|c| c.max_per_page = 10 }
        Kaminari.configure {|c| c.max_per_page = 20 }
      end

      describe '#limit_value' do
        subject { super().limit_value }
        it { is_expected.to eq(20) }
      end
    end

    after do
      Kaminari.configure {|c| c.max_per_page = nil }
      model.max_paginates_per nil
    end
  end

  describe "#max_pages" do
    if defined? ActiveRecord
      describe 'AR::Base' do
        subject { ActiveRecord::Base }
        it { is_expected.not_to respond_to :max_paginates_per }
      end
    end

    before do
      100.times do |count|
        model.create!(:name => "User#{count}")
      end
    end

    subject { model.page(1).per(5) }

    context "by default" do
      describe '#total_pages' do
        subject { super().total_pages }
        it { is_expected.to eq(20) }
      end
    end

    context "when configuring both on global and model-level" do
      before do
        Kaminari.configure {|c| c.max_pages = 10 }
        model.max_pages_per 15
      end

      describe '#total_pages' do
        subject { super().total_pages }
        it { is_expected.to eq(15) }
      end
    end

    context "when configuring multiple times" do
      before do
        Kaminari.configure {|c| c.max_pages = 10 }
        Kaminari.configure {|c| c.max_pages = 15 }
      end

      describe '#total_pages' do
        subject { super().total_pages }
        it { is_expected.to eq(15) }
      end
    end

    after do
      Kaminari.configure {|c| c.max_pages = nil }
      model.max_pages_per nil
    end
  end
end
