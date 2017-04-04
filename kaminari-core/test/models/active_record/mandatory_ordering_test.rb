# frozen_string_literal: true
require 'test_helper'

if defined? ActiveRecord
  class ActiveRecordMandatoryOrderingTest < ActiveSupport::TestCase
    def with_mandatory_ordering_flag(mandatory_ordering_flag)
      Kaminari.configure { |config| config.mandatory_ordering = mandatory_ordering_flag }

      yield
    ensure
      Kaminari.configure {|config| config.mandatory_ordering = false }
    end

    test 'Raises error when mandatory ordering is enabled and paged relation is not ordered' do
      with_mandatory_ordering_flag(true) do
        assert_raise Kaminari::CollectionNotOrderedError do
          User.page(1)
        end
      end
    end

    test 'Does not raise error when mandatory ordering is enabled and paged relation is ordered' do
      with_mandatory_ordering_flag(true) do
        assert_nothing_raised do
          User.order(:id).page(1)
        end
      end
    end

    test 'Does not raise error when mandatory ordering is disabled and paged relation is not ordered' do
      with_mandatory_ordering_flag(false) do
        assert_nothing_raised do
          User.page(1)
        end
      end
    end

    test 'Should recognize order set in default scope' do
      with_mandatory_ordering_flag(true) do
        klass = Class.new(ActiveRecord::Base) do
          self.table_name = 'users'
          default_scope { order(:id) }
        end

        assert_nothing_raised do
          klass.page(1)
        end
      end
    end
  end
end


