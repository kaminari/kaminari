# frozen_string_literal: true

require 'test_helper'

if defined? ActiveRecord
  class ActiveRecordModelExtensionTest < ActiveSupport::TestCase
    test 'An AR model responds to Kaminari defined methods page' do
      assert_respond_to Class.new(ActiveRecord::Base), :page
    end

    test 'An AR model responds to Kaminari defined methods before' do
      assert_respond_to Class.new(ActiveRecord::Base), :before
    end

    test 'An AR model responds to Kaminari defined methods after' do
      assert_respond_to Class.new(ActiveRecord::Base), :after
    end

    test "Kaminari doesn't prevent other AR extension gems to define a method" do
      assert_respond_to Class.new(ActiveRecord::Base), :fake_gem_defined_method
    end
  end
end
