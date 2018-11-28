# frozen_string_literal: true

require 'test_helper'

if defined?(::Rails::Railtie) && defined?(ActionView)
  class TagTest < ActionView::TestCase
    sub_test_case '#page_url_for' do
      setup do
        self.params[:controller] = 'users'
        self.params[:action]     = 'index'
      end

      sub_test_case 'for first page' do
        test 'by default' do
          assert_equal '/users', Kaminari::Helpers::Tag.new(self).page_url_for(1)
        end

        test 'config.params_on_first_page == true' do
          begin
            Kaminari.config.params_on_first_page = true
            assert_equal '/users?page=1', Kaminari::Helpers::Tag.new(self).page_url_for(1)
          ensure
            Kaminari.config.params_on_first_page = false
          end
        end
      end

      sub_test_case 'with a friendly route setting' do
        setup do
          self.params[:controller] = 'addresses'
          self.params[:action]     = 'index'
          self.params[:page]       = 3
        end

        sub_test_case 'for first page' do
          test 'by default' do
            assert_equal('/addresses', Kaminari::Helpers::Tag.new(self).page_url_for(1))
          end

          test 'config.params_on_first_page == true' do
            begin
              Kaminari.config.params_on_first_page = true
              assert_equal('/addresses/page/1', Kaminari::Helpers::Tag.new(self).page_url_for(1))
            ensure
              Kaminari.config.params_on_first_page = false
            end
          end
        end

        test 'for other page' do
          assert_equal('/addresses/page/5', Kaminari::Helpers::Tag.new(self).page_url_for(5))
        end
      end

      sub_test_case "with param_name = 'user[page]' option" do
        setup do
          self.params[:user] = {page: '3', scope: 'active'}
        end

        test 'for first page' do
          assert_not_match(/user%5Bpage%5D=\d+/, Kaminari::Helpers::Tag.new(self, param_name: 'user[page]').page_url_for(1))  # not match user[page]=\d+
          assert_match(/user%5Bscope%5D=active/, Kaminari::Helpers::Tag.new(self, param_name: 'user[page]').page_url_for(1))  # match user[scope]=active
        end

        test 'for other page' do
          assert_match(/user%5Bpage%5D=2/, Kaminari::Helpers::Tag.new(self, param_name: 'user[page]').page_url_for(2))  # match user[page]=2
          assert_match(/user%5Bscope%5D=active/, Kaminari::Helpers::Tag.new(self, param_name: 'user[page]').page_url_for(2))  # match user[scope]=active
        end
      end

      sub_test_case "with param_name = 'foo.page' option" do
        setup do
          self.params['foo.page'] = 2
        end

        test 'for first page' do
          assert_not_match(/foo\.page=\d+/, Kaminari::Helpers::Tag.new(self, param_name: 'foo.page').page_url_for(1))
        end

        test 'for other page' do
          assert_match(/foo\.page=\d+/, Kaminari::Helpers::Tag.new(self, param_name: 'foo.page').page_url_for(2))
        end
      end
    end
  end

  class PaginatorTest < ActionView::TestCase
    test '#current?' do
      # current_page == page
      assert_true Kaminari::Helpers::Paginator::PageProxy.new({current_page: 26}, 26, nil).current?
      # current_page != page
      assert_false Kaminari::Helpers::Paginator::PageProxy.new({current_page: 13}, 26, nil).current?
    end

    test '#first?' do
      # page == 1
      assert_true Kaminari::Helpers::Paginator::PageProxy.new({current_page: 26}, 1, nil).first?
      # page != 1
      assert_false Kaminari::Helpers::Paginator::PageProxy.new({current_page: 13}, 2, nil).first?
    end

    test '#last?' do
      # current_page == page
      assert_true Kaminari::Helpers::Paginator::PageProxy.new({total_pages: 39}, 39, nil).last?
      # current_page != page
      assert_false Kaminari::Helpers::Paginator::PageProxy.new({total_pages: 39}, 38, nil).last?
    end

    test '#next?' do
      # page == current_page + 1
      assert_true Kaminari::Helpers::Paginator::PageProxy.new({current_page: 52}, 53, nil).next?
      # page != current_page + 1
      assert_false Kaminari::Helpers::Paginator::PageProxy.new({current_page: 52}, 77, nil).next?
    end

    test '#prev?' do
      # page == current_page - 1
      assert_true Kaminari::Helpers::Paginator::PageProxy.new({current_page: 77}, 76, nil).prev?
      # page != current_page + 1
      assert_false Kaminari::Helpers::Paginator::PageProxy.new({current_page: 77}, 80, nil).prev?
    end

    test '#rel' do
      # page == current_page - 1
      assert_equal 'prev', Kaminari::Helpers::Paginator::PageProxy.new({current_page: 77}, 76, nil).rel
      # page == current_page
      assert_nil Kaminari::Helpers::Paginator::PageProxy.new({current_page: 78}, 78, nil).rel
      # page == current_page + 1
      assert_equal 'next', Kaminari::Helpers::Paginator::PageProxy.new({current_page: 52}, 53, nil).rel
    end

    test '#left_outer?' do
      # current_page == left
      assert_true Kaminari::Helpers::Paginator::PageProxy.new({left: 3}, 3, nil).left_outer?
      # current_page == left + 1
      assert_false Kaminari::Helpers::Paginator::PageProxy.new({left: 3}, 4, nil).left_outer?
      # current_page == left + 2
      assert_false Kaminari::Helpers::Paginator::PageProxy.new({left: 3}, 5, nil).left_outer?
    end

    test '#right_outer?' do
      # total_pages - page > right
      assert_false Kaminari::Helpers::Paginator::PageProxy.new({total_pages: 10, right: 3}, 6, nil).right_outer?
      # total_pages - page == right
      assert_false Kaminari::Helpers::Paginator::PageProxy.new({total_pages: 10, right: 3}, 7, nil).right_outer?
      # total_pages - page < right
      assert_true Kaminari::Helpers::Paginator::PageProxy.new({total_pages: 10, right: 3}, 8, nil).right_outer?
    end

    sub_test_case '#inside_window?' do
      test 'page > current_page' do
        # page - current_page > window
        assert_false Kaminari::Helpers::Paginator::PageProxy.new({current_page: 4, window: 5}, 10, nil).inside_window?
        # page - current_page == window
        assert_true Kaminari::Helpers::Paginator::PageProxy.new({current_page: 4, window: 6}, 10, nil).inside_window?
        # page - current_page < window
        assert_true Kaminari::Helpers::Paginator::PageProxy.new({current_page: 4, window: 7}, 10, nil).inside_window?
      end

      test 'current_page > page' do
        # current_page - page > window
        assert_false Kaminari::Helpers::Paginator::PageProxy.new({current_page: 15, window: 4}, 10, nil).inside_window?
        # current_page - page == window
        assert_true Kaminari::Helpers::Paginator::PageProxy.new({current_page: 15, window: 5}, 10, nil).inside_window?
        # current_page - page < window
        assert_true Kaminari::Helpers::Paginator::PageProxy.new({current_page: 15, window: 6}, 10, nil).inside_window?
      end
    end

    sub_test_case '#was_truncated?' do
      setup do
        stub(@template = Object.new) do
          options { {} }
          params { {} }
        end
      end

      test 'last.is_a? Gap' do
        assert_true Kaminari::Helpers::Paginator::PageProxy.new({}, 10, Kaminari::Helpers::Gap.new(@template)).was_truncated?
      end

      test 'last.is not a Gap' do
        assert_false Kaminari::Helpers::Paginator::PageProxy.new({}, 10, Kaminari::Helpers::Page.new(@template)).was_truncated?
      end
    end

    sub_test_case '#single_gap?' do
      setup do
        @window_options = {left: 1, window: 1, right: 1, total_pages: 9}
      end

      def gap_for(page)
        Kaminari::Helpers::Paginator::PageProxy.new(@window_options, page, nil)
      end

      test "in case of '1 ... 4 5 6 ... 9'" do
        @window_options[:current_page] = 5

        assert_false gap_for(2).single_gap?
        assert_false gap_for(3).single_gap?
        assert_false gap_for(7).single_gap?
        assert_false gap_for(8).single_gap?
      end

      test "in case of '1 ... 3 4 5 ... 9'" do
        @window_options[:current_page] = 4

        assert_true gap_for(2).single_gap?
        assert_false gap_for(6).single_gap?
        assert_false gap_for(8).single_gap?
      end

      test "in case of '1 ... 3 4 5 ... 7'" do
        @window_options[:current_page] = 4
        @window_options[:total_pages] = 7

        assert_true gap_for(2).single_gap?
        assert_true gap_for(6).single_gap?
      end

      test "in case of '1 ... 5 6 7 ... 9'" do
        @window_options[:current_page] = 6

        assert_false gap_for(2).single_gap?
        assert_false gap_for(4).single_gap?
        assert_true gap_for(8).single_gap?
      end
    end

    test '#out_of_range?' do
      # within range
      assert_false Kaminari::Helpers::Paginator::PageProxy.new({total_pages: 5}, 4, nil).out_of_range?
      # on last page
      assert_false Kaminari::Helpers::Paginator::PageProxy.new({total_pages: 5}, 5, nil).out_of_range?
      # out of range
      assert_true Kaminari::Helpers::Paginator::PageProxy.new({total_pages: 5}, 6, nil).out_of_range?
    end
  end
end
