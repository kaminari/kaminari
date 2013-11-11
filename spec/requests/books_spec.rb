# encoding: UTF-8
require 'spec_helper'

if defined?(ActiveRecord) && !defined?(Sinatra)
  feature 'Books' do
    background do
      user = User.create! :name => "user0"
      1.upto(100) {|i| user.books_authored.create!(:title => "title%03d" % i) }
    end
    scenario 'navigating by pagination links' do
      visit '/users/1/books'

      within '.head' do
        all('link').count.should == 1
        find('link[rel="next"][href="/users/1/books?page=2"]')
      end

      within 'nav.pagination' do
        within 'span.page.current' do
          page.should have_content '1'
        end
        within 'span.next' do
          click_link 'Next ›'
        end
      end

      within '.head' do
        all('link').count.should == 2
        find('link[rel="prev"][href="/users/1/books?page=1"]')
        find('link[rel="next"][href="/users/1/books?page=3"]')
      end

      within 'nav.pagination' do
        within 'span.page.current' do
          page.should have_content '2'
        end
        within 'span.last' do
          click_link 'Last »'
        end
      end

      within '.head' do
        all('link').count.should == 1
        find('link[rel="prev"][href="/users/1/books?page=3"]')
      end

      within 'nav.pagination' do
        within 'span.page.current' do
          page.should have_content '4'
        end
        within 'span.prev' do
          click_link '‹ Prev'
        end
      end

      within '.head' do
        all('link').count.should == 2
        find('link[rel="prev"][href="/users/1/books?page=2"]')
        find('link[rel="next"][href="/users/1/books?page=4"]')
      end

      within 'nav.pagination' do
        within 'span.page.current' do
          page.should have_content '3'
        end
        within 'span.first' do
          click_link '« First'
        end
      end

      within '.head' do
        all('link').count.should == 1
        find('link[rel="next"][href="/users/1/books?page=2"]')
      end

      within 'nav.pagination' do
        within 'span.page.current' do
          page.should have_content '1'
        end
      end
    end
  end
end
