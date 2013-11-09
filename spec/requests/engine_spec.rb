# encoding: UTF-8
require 'spec_helper'

feature 'Pagination properly works in mouted Engines' do
  background do
    1.upto(50) {|i| User.create! :name => "user#{'%02d' % i}" }
  end
  scenario 'Showing normal pagination links' do
    visit '/engine/users'

    within 'nav.pagination' do
      within 'span.page.current' do
        page.should have_content '1'
      end
      within 'span.next' do
        click_link 'Next ›'
      end
    end

    within 'nav.pagination' do
      within 'span.page.current' do
        page.should have_content '2'
      end
    end
  end
end if Rails.version > '3.1.0' # it works with Sinatra tests! :)