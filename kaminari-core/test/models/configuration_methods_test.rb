# frozen_string_literal: true

require 'test_helper'

class ConfigurationMethodsTest < ActiveSupport::TestCase
  sub_test_case '#default_per_page' do
    if defined? ActiveRecord
      test 'AR::Base should be not polluted by configuration methods' do
        assert_not_respond_to ActiveRecord::Base, :paginates_per
      end
    end

    test 'by default' do
      assert_equal 25, User.page(1).limit_value
    end

    test 'when configuring both on global and model-level' do
      Kaminari.configure {|c| c.default_per_page = 50 }
      User.paginates_per 100

      assert_equal 100, User.page(1).limit_value
    end

    test 'when configuring multiple times' do
      Kaminari.configure {|c| c.default_per_page = 10 }
      Kaminari.configure {|c| c.default_per_page = 20 }

      assert_equal 20, User.page(1).limit_value
    end

    teardown do
      Kaminari.configure {|c| c.default_per_page = 25 }
      User.paginates_per nil
    end
  end

  sub_test_case '#max_per_page' do
    teardown do
      Kaminari.configure {|c| c.max_per_page = nil }
      User.max_paginates_per nil
    end

    if defined? ActiveRecord
      test 'AR::Base should be not polluted by configuration methods' do
        assert_not_respond_to ActiveRecord::Base, :max_paginates_per
      end
    end

    test 'by default' do
      assert_equal 1000, User.page(1).per(1000).limit_value
    end

    test 'when configuring both on global and model-level' do
      Kaminari.configure {|c| c.max_per_page = 50 }
      User.max_paginates_per 100

      assert_equal 100, User.page(1).per(1000).limit_value
    end

    test 'when configuring multiple times' do
      Kaminari.configure {|c| c.max_per_page = 10 }
      Kaminari.configure {|c| c.max_per_page = 20 }

      assert_equal 20, User.page(1).per(1000).limit_value
    end
  end

  sub_test_case '#max_pages' do
    if defined? ActiveRecord
      test 'AR::Base should be not polluted by configuration methods' do
        assert_not_respond_to ActiveRecord::Base, :max_pages
      end
    end

    setup do
      100.times do |count|
        User.create!(name: "User#{count}")
      end
    end

    teardown do
      Kaminari.configure {|c| c.max_pages = nil }
      User.max_pages nil
      User.delete_all
    end

    test 'by default' do
      assert_equal 20, User.page(1).per(5).total_pages
    end

    test 'when configuring both on global and model-level' do
      Kaminari.configure {|c| c.max_pages = 10 }
      User.max_pages 15

      assert_equal 15, User.page(1).per(5).total_pages
    end

    test 'when configuring multiple times' do
      Kaminari.configure {|c| c.max_pages = 10 }
      Kaminari.configure {|c| c.max_pages = 15 }

      assert_equal 15, User.page(1).per(5).total_pages
    end
  end
end
