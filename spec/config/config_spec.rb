require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Kaminari::Configuration do
  subject { Kaminari.config }
  describe 'default_per_page' do
    context 'by default' do
      its(:default_per_page) { should == 25 }
    end
    context 'configured via config block' do
      before do
        Kaminari.configure {|c| c.default_per_page = 17}
      end
      its(:default_per_page) { should == 17 }
      after do
        Kaminari.configure {|c| c.default_per_page = 25}
      end
    end
  end
end
