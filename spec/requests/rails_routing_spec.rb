# encoding: UTF-8
require 'spec_helper'

if defined?(ActiveRecord) && !defined?(Sinatra)
  feature 'Users' do
    background do
      1.upto(100) {|i| User.create! :name => "user#{'%03d' % i}" }
    end
    scenario 'navigating by pagination links with extra params' do
      def find_page(page)
        # Rails 3.2 and later are able to create the URL from the routes
        # without simply converting everything to parameters, so we can locate
        # links based on their fully formed URL. Earlier versions will simply
        # append the params at the end of the URL (generating more ugly results
        # that we don't want to check here).
        if ActiveRecord::VERSION::STRING >= "3.2.0"
          find(".page a[href='/users/hello/world/page/#{page}']")
        else
          find(".page a", :text => page.to_s)
        end
      end

      visit '/users/hello/world/page/1'
      find_page(4).click
      find_page(1).click
    end
  end
end
