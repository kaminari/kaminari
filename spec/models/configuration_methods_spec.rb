require 'spec_helper'

describe "configuration methods" do
  let(:model){ User }

  describe "#default_per_page" do
    if defined? ActiveRecord
      describe 'AR::Base' do
        subject { ActiveRecord::Base }
        it { should_not respond_to :paginates_per }
      end
    end

    subject { model.page(1) }

    context "by default" do
      its(:limit_value){ should == 25 }
    end

    context "when configuring both on global and model-level" do
      before do
        Kaminari.configure {|c| c.default_per_page = 50 }
        model.paginates_per 100
      end

      its(:limit_value){ should == 100 }
    end

    context "when configuring multiple times" do
      before do
        Kaminari.configure {|c| c.default_per_page = 10 }
        Kaminari.configure {|c| c.default_per_page = 20 }
      end

      its(:limit_value){ should == 20 }
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
        it { should_not respond_to :max_pages_per }
      end
    end

    subject { model.page(1).per(1000) }

    context "by default" do
      its(:limit_value){ should == 1000 }
    end

    context "when configuring both on global and model-level" do
      before do
        Kaminari.configure {|c| c.max_per_page = 50 }
        model.max_paginates_per 100
      end

      its(:limit_value){ should == 100 }
    end

    context "when configuring multiple times" do
      before do
        Kaminari.configure {|c| c.max_per_page = 10 }
        Kaminari.configure {|c| c.max_per_page = 20 }
      end

      its(:limit_value){ should == 20 }
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
        it { should_not respond_to :max_paginates_per }
      end
    end

    before do
      100.times do |count|
        model.create!(:name => "User#{count}")
      end
    end

    subject { model.page(1).per(5) }

    context "by default" do
      its(:total_pages){ should == 20 }
    end

    context "when configuring both on global and model-level" do
      before do
        Kaminari.configure {|c| c.max_pages = 10 }
        model.max_pages_per 15
      end

      its(:total_pages){ should == 15 }
    end

    context "when configuring multiple times" do
      before do
        Kaminari.configure {|c| c.max_pages = 10 }
        Kaminari.configure {|c| c.max_pages = 15 }
      end

      its(:total_pages){ should == 15 }
    end

    after do
      Kaminari.configure {|c| c.max_pages = nil }
      model.max_pages_per nil
    end
  end
end
