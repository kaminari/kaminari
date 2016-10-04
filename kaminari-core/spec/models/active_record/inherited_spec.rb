require 'spec_helper'

if defined? ActiveRecord
  describe Kaminari::ActiveRecordModelExtension do
    subject { Class.new(ActiveRecord::Base) }
    it { should respond_to :page }
    it { should respond_to :fake_gem_defined_method }
  end
end
