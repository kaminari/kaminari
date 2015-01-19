require 'spec_helper'

if defined? Sinatra
  ERB_TEMPLATE_FOR_PAGINATE = <<EOT
  <div>
  <ul>
  <% @users.each do |user| %>
    <li class="user_info"><%= user.id %></li>
  <% end %>
  </ul>
  <%= paginate @users, @options %>
  </div>
EOT

  ERB_TEMPLATE_FOR_PREVIOUS_PAGE = <<EOT
  <div>
  <ul>
  <% @users.each do |user| %>
    <li class="user_info"><%= user.id %></li>
  <% end %>
  </ul>
  <%= link_to_previous_page(@users, "Previous!", {:id => 'previous_page_link'}.merge(@options || {})) %>
  </div>
EOT

  ERB_TEMPLATE_FOR_NEXT_PAGE = <<EOT
  <div>
  <ul>
  <% @users.each do |user| %>
    <li class="user_info"><%= user.id %></li>
  <% end %>
  </ul>
  <%= link_to_next_page(@users, "Next!", {:id => 'next_page_link'}.merge(@options || {})) %>
  </div>
EOT

  describe 'Kaminari::Helpers::SinatraHelper', :type => :helper do
    before do
      50.times {|i| User.create! :name => "user#{i}"}
    end

    describe '#paginate' do
      before do
        mock_app do
          register Kaminari::Helpers::SinatraHelpers
          get '/users' do
            @page = params[:page] || 1
            @users = User.page(@page)
            @options = {}
            erb ERB_TEMPLATE_FOR_PAGINATE
          end
        end
      end

      context 'normal paginations with Sinatra' do
        before { get '/users' }

        it 'should have a navigation tag' do
          expect(last_document.search('nav.pagination')).not_to be_empty
        end

        it 'should have pagination links' do
          expect(last_document.search('.page a').size).to be >= 1
          expect(last_document.search('.next a').size).to be >= 1
          expect(last_document.search('.last a').size).to be >= 1
        end

        it 'should point to current page' do
          expect(last_document.search('.current').text).to match(/1/)

          get '/users?page=2'
          expect(last_document.search('.current').text).to match(/2/)
        end

        it 'should load 25 users' do
          expect(last_document.search('li.user_info').size).to eq(25)
        end

        it 'should preserve params' do
          get '/users?foo=bar'
          expect(last_document.search('.page a')).to(be_all do |elm|
            elm.attribute('href').value =~ /foo=bar/
          end)
        end
      end

      context 'optional paginations with Sinatra' do
        it 'should have 5 windows with 1 gap' do
          mock_app do
            register Kaminari::Helpers::SinatraHelpers
            get '/users' do
              @page = params[:page] || 1
              @users = User.page(@page).per(5)
              @options = {}
              erb ERB_TEMPLATE_FOR_PAGINATE
            end
          end

          get '/users'
          expect(last_document.search('.page').size).to eq(6)
          expect(last_document.search('.gap').size).to eq(1)
        end

        it 'should controll the inner window size' do
          mock_app do
            register Kaminari::Helpers::SinatraHelpers
            get '/users' do
              @page = params[:page] || 1
              @users = User.page(@page).per(3)
              @options = {:window => 10}
              erb ERB_TEMPLATE_FOR_PAGINATE
            end
          end

          get '/users'
          expect(last_document.search('.page').size).to eq(12)
          expect(last_document.search('.gap').size).to eq(1)
        end

        it 'should specify a page param name' do
          mock_app do
            register Kaminari::Helpers::SinatraHelpers
            get '/users' do
              @page = params[:page] || 1
              @users = User.page(@page).per(3)
              @options = {:param_name => :user_page}
              erb ERB_TEMPLATE_FOR_PAGINATE
            end
          end

          get '/users'
          expect(last_document.search('.page a')).to(be_all do |elm|
            elm.attribute('href').value =~ /user_page=\d+/
          end)
        end
      end
    end

    describe '#link_to_previous_page' do
      before do
        mock_app do
          register Kaminari::Helpers::SinatraHelpers
          get '/users' do
            @page = params[:page] || 2
            @users = User.page(@page)
            erb ERB_TEMPLATE_FOR_PREVIOUS_PAGE
          end

          get '/users_placeholder' do
            @page = params[:page] || 2
            @options = {:placeholder => %{<span id='no_previous_page'>No Previous Page</span>}}
            @users = User.page(@page)
            erb ERB_TEMPLATE_FOR_PREVIOUS_PAGE
          end
        end
      end

      context 'having more page' do
        it 'should have a more page link' do
          get '/users'
          expect(last_document.search('a#previous_page_link')).to be_present
          expect(last_document.search('a#previous_page_link').text).to match(/Previous!/)
        end
      end

      context 'the first page' do
        it 'should not have a more page link' do
          get '/users?page=1'
          expect(last_document.search('a#previous_page_link')).to be_empty
        end

        it 'should have a no more page notation using placeholder' do
          get '/users_placeholder?page=1'
          expect(last_document.search('a#previous_page_link')).to be_empty
          expect(last_document.search('span#no_previous_page')).to be_present
          expect(last_document.search('span#no_previous_page').text).to match(/No Previous Page/)
        end
      end
    end

    describe '#link_to_next_page' do
      before do
        mock_app do
          register Kaminari::Helpers::SinatraHelpers
          get '/users' do
            @page = params[:page] || 1
            @users = User.page(@page)
            erb ERB_TEMPLATE_FOR_NEXT_PAGE
          end

          get '/users_placeholder' do
            @page = params[:page] || 1
            @options = {:placeholder => %{<span id='no_next_page'>No Next Page</span>}}
            @users = User.page(@page)
            erb ERB_TEMPLATE_FOR_NEXT_PAGE
          end
        end
      end

      context 'having more page' do
        it 'should have a more page link' do
          get '/users'
          expect(last_document.search('a#next_page_link')).to be_present
          expect(last_document.search('a#next_page_link').text).to match(/Next!/)
        end
      end

      context 'the last page' do
        it 'should not have a more page link' do
          get '/users?page=2'
          expect(last_document.search('a#next_page_link')).to be_empty
        end

        it 'should have a no more page notation using placeholder' do
          get '/users_placeholder?page=2'
          expect(last_document.search('a#next_page_link')).to be_empty
          expect(last_document.search('span#no_next_page')).to be_present
          expect(last_document.search('span#no_next_page').text).to match(/No Next Page/)
        end
      end
    end
  end
end
