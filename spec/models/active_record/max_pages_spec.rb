require 'spec_helper'

if defined? ActiveRecord

  describe 'max pages' do
    describe 'AR::Base' do
      subject { ActiveRecord::Base }
      it { should_not respond_to :max_pages_per }
    end

    subject { User.page 0 }

    context 'by default' do
      its(:max_pages) { should == nil }
    end

    context 'when explicitly set via max_pages_per' do
      before { User.max_pages_per 3 }
      its(:max_pages) { should == 3 }
      after { User.max_pages_per nil }
    end
  end
end
