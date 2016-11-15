# encoding: UTF-8
# frozen_string_literal: true
require 'spec_helper'

feature 'Rendering with format: option' do
  background do
    User.create! :name => "user1"
  end
  scenario "Make sure that kaminari doesn't affect the format" do
    visit '/users/index_text.text'

    page.status_code.should == 200
    page.should have_content 'partial1'
    page.should have_content 'partial2'
  end
end
