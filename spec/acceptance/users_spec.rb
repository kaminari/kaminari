# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'Users' do
  background do
    1.upto(100) {|i| User.create! :name => "user#{'%03d' % i}" }
  end
  scenario 'navigating by pagination links' do
    visit users_path

    within 'nav.pagination' do
      within 'span.page.current' do
        page.should have_content '1'
      end
      within 'span.next' do
        click_link 'Next »'
      end
    end

    within 'nav.pagination' do
      within 'span.page.current' do
        page.should have_content '2'
      end
      within 'span.page.last' do
        click_link '4'
      end
    end

    within 'nav.pagination' do
      within 'span.page.current' do
        page.should have_content '4'
      end
      within 'span.prev' do
        click_link '« Prev'
      end
    end

    within 'nav.pagination' do
      within 'span.page.current' do
        page.should have_content '3'
      end
    end
  end
end
