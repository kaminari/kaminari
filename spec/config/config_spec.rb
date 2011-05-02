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

  describe 'window' do
    context 'by default' do
      its(:window) { should == 4 }
    end
  end

  describe 'outer_window' do
    context 'by default' do
      its(:outer_window) { should == 0 }
    end
  end

  describe 'left' do
    context 'by default' do
      its(:left) { should == 0 }
    end
  end

  describe 'right' do
    context 'by default' do
      its(:right) { should == 0 }
    end
  end

  describe 'param_name' do
    context 'by default' do
      its(:param_name) { should == :page }
    end

    context 'configured via block' do
      before do
        Kaminari.configure {|c| c.param_name { :test } }
      end

      its(:param_name) { should == :test }

      after do 
        Kaminari.configure {|c| c.param_name = :page }
      end
    end

    context 'configured via config lambda/proc' do
      before do
        Kaminari.configure {|c| c.param_name = lambda { :test } }
      end

      its(:param_name) { should == :test }

      after do 
        Kaminari.configure {|c| c.param_name = :page }
      end
    end
  end
end
