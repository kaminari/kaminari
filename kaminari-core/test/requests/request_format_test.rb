# frozen_string_literal: true

require 'test_helper'

class RenderingWithFormatOptionTest < Test::Unit::TestCase
  include Capybara::DSL

  setup do
    User.create! name: 'user1'
  end

  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
    User.delete_all
  end

  test "Make sure that kaminari doesn't affect the format" do
    visit '/users/index_text.text'

    assert_equal 200, page.status_code
    assert page.has_content? 'partial1'
    assert page.has_content? 'partial2'
  end
end
