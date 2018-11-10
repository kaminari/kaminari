# frozen_string_literal: true

require 'test_helper'

class ConfigurationTest < ::Test::Unit::TestCase
  sub_test_case 'default_per_page' do
    test 'by default' do
      assert_equal 25, Kaminari.config.default_per_page
    end
    test 'configured via config block' do
      begin
        Kaminari.configure {|c| c.default_per_page = 17}
        assert_equal 17, Kaminari.config.default_per_page
      ensure
        Kaminari.configure {|c| c.default_per_page = 25}
      end
    end
  end

  sub_test_case 'max_per_page' do
    test 'by default' do
      assert_nil Kaminari.config.max_per_page
    end
    test 'configure via config block' do
      begin
        Kaminari.configure {|c| c.max_per_page = 100}
        assert_equal 100, Kaminari.config.max_per_page
      ensure
        Kaminari.configure {|c| c.max_per_page = nil}
      end
    end
  end

  sub_test_case 'window' do
    test 'by default' do
      assert_equal 4, Kaminari.config.window
    end
  end

  sub_test_case 'outer_window' do
    test 'by default' do
      assert_equal 0, Kaminari.config.outer_window
    end
  end

  sub_test_case 'left' do
    test 'by default' do
      assert_equal 0, Kaminari.config.left
    end
  end

  sub_test_case 'right' do
    test 'by default' do
      assert_equal 0, Kaminari.config.right
    end
  end

  sub_test_case 'param_name' do
    test 'by default' do
      assert_equal :page, Kaminari.config.param_name
    end
    test 'configured via config block' do
      begin
        Kaminari.configure {|c| c.param_name = -> { :test } }
        assert_equal :test, Kaminari.config.param_name
      ensure
        Kaminari.configure {|c| c.param_name = :page }
      end
    end
  end

  sub_test_case 'max_pages' do
    test 'by default' do
      assert_nil Kaminari.config.max_pages
    end
    test 'configure via config block' do
      begin
        Kaminari.configure {|c| c.max_pages = 5}
        assert_equal 5, Kaminari.config.max_pages
      ensure
        Kaminari.configure {|c| c.max_pages = nil}
      end
    end
  end

  sub_test_case 'params_on_first_page' do
    test 'by default' do
      assert_equal false, Kaminari.config.params_on_first_page
    end
    test 'configure via config block' do
      begin
        Kaminari.configure {|c| c.params_on_first_page = true }
        assert_equal true, Kaminari.config.params_on_first_page
      ensure
        Kaminari.configure {|c| c.params_on_first_page = false }
      end
    end
  end
end
