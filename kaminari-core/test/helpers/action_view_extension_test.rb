# frozen_string_literal: true

require 'test_helper'

if defined?(::Rails::Railtie) && defined?(::ActionView)
  class ActionViewExtensionTest < ActionView::TestCase
    setup do
      self.output_buffer = ::ActionView::OutputBuffer.new
      I18n.available_locales = [:en, :de, :fr]
      I18n.locale = :en
    end
    teardown do
      User.delete_all
    end
    sub_test_case '#paginate' do
      setup do
        50.times {|i| User.create! name: "user#{i}"}
      end

      test 'returns a String' do
        users = User.page(1)
        assert_kind_of String, view.paginate(users, params: {controller: 'users', action: 'index'})
      end

      test 'escaping the pagination for javascript' do
        users = User.page(1)
        assert_nothing_raised do
          escape_javascript(view.paginate users, params: {controller: 'users', action: 'index'})
        end
      end

      test 'allows for overriding params with the :params option' do
        view.params[:controller], view.params[:action] = 'addresses', 'new'
        users = User.page(1)

        assert_match '/users?page=2', view.paginate(users, params: { controller: 'users', action: 'index' })
      end

      test 'accepts :theme option' do
        users = User.page(1)
        begin
          controller.append_view_path File.join(Gem.loaded_specs['kaminari-core'].gem_dir, 'test/fake_app/views')

          html = view.paginate users, theme: 'bootstrap', params: {controller: 'users', action: 'index'}
          assert_match(/bootstrap-paginator/, html)
          assert_match(/bootstrap-page-link/, html)
        ensure
          controller.view_paths.pop
        end
      end

      test 'accepts :views_prefix option' do
        users = User.page(1)
        begin
          controller.append_view_path File.join(Gem.loaded_specs['kaminari-core'].gem_dir, 'test/fake_app/views')

          assert_equal "  <b>1</b>\n", view.paginate(users, views_prefix: 'alternative/', params: {controller: 'users', action: 'index'})
        ensure
          controller.view_paths.pop
        end
      end

      test 'accepts :paginator_class option' do
        users = User.page(1)
        custom_paginator = Class.new(Kaminari::Helpers::Paginator) do
          def to_s
            "CUSTOM PAGINATION"
          end
        end

        assert_equal 'CUSTOM PAGINATION', view.paginate(users, paginator_class: custom_paginator, params: {controller: 'users', action: 'index'})
      end

      test 'total_pages: 3' do
        users = User.page(1)
        assert_match(/<a href="\/users\?page=3">Last/, view.paginate(users, total_pages: 3, params: {controller: 'users', action: 'index'}))
      end

      test "page: 20 (out of range)" do
        users = User.page(20)

        html = view.paginate users, params: {controller: 'users', action: 'index'}
        assert_not_match(/Last/, html)
        assert_not_match(/Next/, html)
      end
    end

    sub_test_case '#link_to_previous_page' do
      setup do
        60.times {|i| User.create! name: "user#{i}"}
      end

      sub_test_case 'having previous pages' do
        test 'the default behaviour' do
          users = User.page(3)
          html = view.link_to_previous_page users, 'Previous', params: {controller: 'users', action: 'index'}
          assert_match(/page=2/, html)
          assert_match(/rel="prev"/, html)

          html = view.link_to_previous_page users, 'Previous', params: {controller: 'users', action: 'index'} do 'At the Beginning' end
          assert_match(/page=2/, html)
          assert_match(/rel="prev"/, html)
        end

        test 'overriding rel=' do
          users = User.page(3)
          assert_match(/rel="external"/, view.link_to_previous_page(users, 'Previous', rel: 'external', params: {controller: 'users', action: 'index'}))
        end

        test 'with params' do
          users = User.page(3)
          params[:status] = 'active'

          assert_match(/status=active/, view.link_to_previous_page(users, 'Previous', params: {controller: 'users', action: 'index'}))
        end
      end

      test 'the first page' do
        users = User.page(1)

        assert_nil view.link_to_previous_page(users, 'Previous', params: {controller: 'users', action: 'index'})
        assert_equal 'At the Beginning', (view.link_to_previous_page(users, 'Previous', params: {controller: 'users', action: 'index'}) do 'At the Beginning' end)
      end

      test 'out of range' do
        users = User.page(5)

        assert_nil view.link_to_previous_page(users, 'Previous', params: {controller: 'users', action: 'index'})
        assert_equal 'At the Beginning', (view.link_to_previous_page(users, 'Previous', params: {controller: 'users', action: 'index'}) do 'At the Beginning' end)
      end

      test '#link_to_previous_page accepts ActionController::Parameters' do
        users = User.page(3)
        params = ActionController::Parameters.new(controller: 'users', action: 'index', status: 'active')

        html = view.link_to_previous_page users, 'Previous', params: params

        assert_match(/page=2/, html)
        assert_match(/rel="prev"/, html)
        assert_match(/status=active/, html)
      end
    end

    sub_test_case '#link_to_next_page' do
      setup do
        50.times {|i| User.create! name: "user#{i}"}
      end

      sub_test_case 'having more page' do
        test 'the default behaviour' do
          users = User.page(1)
          html = view.link_to_next_page users, 'More', params: {controller: 'users', action: 'index'}

          assert_match(/page=2/, html)
          assert_match(/rel="next"/, html)
        end

        test 'overriding rel=' do
          users = User.page(1)

          assert_match(/rel="external"/, view.link_to_next_page(users, 'More', rel: 'external', params: {controller: 'users', action: 'index'}))
        end

        test 'with params' do
          users = User.page(1)
          params[:status] = 'active'

          assert_match(/status=active/, view.link_to_next_page(users, 'More', params: {controller: 'users', action: 'index'}))
        end
      end

      test 'the last page' do
        users = User.page(2)

        assert_nil view.link_to_next_page(users, 'More', params: {controller: 'users', action: 'index'})
      end

      test 'out of range' do
        users = User.page(5)

        assert_nil view.link_to_next_page(users, 'More', params: {controller: 'users', action: 'index'})
      end

      test '#link_to_next_page accepts ActionController::Parameters' do
        users = User.page(1)
        params = ActionController::Parameters.new(controller: 'users', action: 'index', status: 'active')

        html = view.link_to_next_page users, 'More', params: params

        assert_match(/page=2/, html)
        assert_match(/rel="next"/, html)
        assert_match(/status=active/, html)
      end
    end

    sub_test_case '#page_entries_info' do
      sub_test_case 'on a model without namespace' do
        sub_test_case 'having no entries' do
          test 'with default entry name' do
            users = User.page(1).per(25)
            assert_equal 'No users found', view.page_entries_info(users)
          end

          test 'setting the entry name option to "member"' do
            users = User.page(1).per(25)
            assert_equal 'No members found', view.page_entries_info(users, entry_name: 'member')
          end
        end

        sub_test_case 'having 1 entry' do
          setup do
            User.create! name: 'user1'
          end

          test 'with default entry name' do
            users = User.page(1).per(25)
            assert_equal 'Displaying <b>1</b> user', view.page_entries_info(users)
          end

          test 'setting the entry name option to "member"' do
            users = User.page(1).per(25)
            assert_equal 'Displaying <b>1</b> member', view.page_entries_info(users, entry_name: 'member')
          end
        end

        sub_test_case 'having more than 1 but less than a page of entries' do
          setup do
            10.times {|i| User.create! name: "user#{i}"}
          end

          test 'with default entry name' do
            users = User.page(1).per(25)
            assert_equal 'Displaying <b>all 10</b> users', view.page_entries_info(users)
          end

          test 'setting the entry name option to "member"' do
            users = User.page(1).per(25)
            assert_equal 'Displaying <b>all 10</b> members', view.page_entries_info(users, entry_name: 'member')
          end
        end

        sub_test_case 'having more than one page of entries' do
          setup do
            50.times {|i| User.create! name: "user#{i}"}
          end

          sub_test_case 'the first page' do
            test 'with default entry name' do
              users = User.page(1).per(25)
              assert_equal 'Displaying users <b>1&nbsp;-&nbsp;25</b> of <b>50</b> in total', view.page_entries_info(users)
            end

            test 'setting the entry name option to "member"' do
              users = User.page(1).per(25)
              assert_equal 'Displaying members <b>1&nbsp;-&nbsp;25</b> of <b>50</b> in total', view.page_entries_info(users, entry_name: 'member')
            end
          end

          sub_test_case 'the next page' do
            test 'with default entry name' do
              users = User.page(2).per(25)
              assert_equal 'Displaying users <b>26&nbsp;-&nbsp;50</b> of <b>50</b> in total', view.page_entries_info(users)
            end

            test 'setting the entry name option to "member"' do
              users = User.page(2).per(25)
              assert_equal 'Displaying members <b>26&nbsp;-&nbsp;50</b> of <b>50</b> in total', view.page_entries_info(users, entry_name: 'member')
            end
          end

          sub_test_case 'the last page' do
            test 'with default entry name' do
              begin
                User.max_pages 4
                users = User.page(4).per(10)

                assert_equal 'Displaying users <b>31&nbsp;-&nbsp;40</b> of <b>40</b> in total', view.page_entries_info(users)
              ensure
                User.max_pages nil
              end
            end
          end

          test 'it accepts a decorated object' do
            page_info_presenter = Class.new(SimpleDelegator) do
              include ActionView::Helpers::NumberHelper

              def total_count
                number_with_delimiter(1_000)
              end
            end

            users = page_info_presenter.new(User.page(1).per(25))

            assert_equal 'Displaying users <b>1&nbsp;-&nbsp;25</b> of <b>1,000</b> in total', view.page_entries_info(users)
          end
        end
      end

      sub_test_case 'I18n' do
        setup do
          50.times {|i| User.create! name: "user#{i}"}
        end

        test 'page_entries_info translates entry' do
          users = User.page(1).per(25)
          begin
            I18n.backend.store_translations(:en, User.i18n_scope => { models: { user: { one: "person", other: "people" } } })

            assert_equal 'Displaying people <b>1&nbsp;-&nbsp;25</b> of <b>50</b> in total', view.page_entries_info(users)
          ensure
            I18n.backend.reload!
          end
        end

        sub_test_case 'with any other locale' do
          teardown do
            I18n.backend.reload!
          end

          sub_test_case ':de' do
            setup do
              I18n.locale = :de
              I18n.backend.store_translations(:de,
                helpers: {
                  page_entries_info: {
                    one_page: {
                      display_entries: {
                        one: "Displaying <b>1</b> %{entry_name}",
                        other: "Displaying <b>all %{count}</b> %{entry_name}"
                      }
                    },
                    more_pages: {
                      display_entries: "Displaying %{entry_name} <b>%{first}&nbsp;-&nbsp;%{last}</b> of <b>%{total}</b> in total"
                    }
                  }
                }
              )
            end

            test 'with default entry name' do
              users = User.page(1).per(50)
              assert_equal 'Displaying <b>all 50</b> Benutzer', view.page_entries_info(users,  entry_name: 'Benutzer')
            end

            test 'the last page with default entry name' do
              users = User.page(5).per(10)
              assert_equal 'Displaying Benutzer <b>41&nbsp;-&nbsp;50</b> of <b>50</b> in total', view.page_entries_info(users,  entry_name: 'Benutzer')
            end
          end
        end

        sub_test_case ':fr' do
          setup do
            I18n.locale = :fr
            ActiveSupport::Inflector.inflections(:fr) do |inflect|
              inflect.plural(/$/, 's')
              inflect.singular(/s$/, '')
            end
            I18n.backend.store_translations(:fr,
              helpers: {
                page_entries_info: {
                  one_page: {
                    display_entries: {
                      one: "Displaying <b>1</b> %{entry_name}",
                      other: "Displaying <b>all %{count}</b> %{entry_name}"
                    }
                  },
                  more_pages: {
                    display_entries: "Displaying %{entry_name} <b>%{first}&nbsp;-&nbsp;%{last}</b> of <b>%{total}</b> in total"
                  }
                }
              }
            )
          end

          sub_test_case 'having 1 entry' do
            setup do
              User.delete_all
              User.create! name: 'user1'
            end

            test 'with default entry name' do
              users = User.page(1).per(25)
              assert_equal 'Displaying <b>1</b> utilisateur', view.page_entries_info(users,  entry_name: 'utilisateur')
            end
          end

          test 'having multiple entries with default entry name' do
            users = User.page(1).per(50)
            assert_equal 'Displaying <b>all 50</b> utilisateurs', view.page_entries_info(users,  entry_name: 'utilisateur')
          end

          test 'the last page with default entry name' do
            users = User.page(5).per(10)
            assert_equal 'Displaying utilisateurs <b>41&nbsp;-&nbsp;50</b> of <b>50</b> in total', view.page_entries_info(users,  entry_name: 'utilisateur')
          end
        end
      end

      sub_test_case 'on a model with namespace' do
        teardown do
          User::Address.delete_all
        end

        test 'having no entries' do
          addresses = User::Address.page(1).per(25)
          assert_equal 'No addresses found', view.page_entries_info(addresses)
        end

        sub_test_case 'having 1 entry' do
          setup do
            User::Address.create!
          end

          test 'with default entry name' do
            addresses = User::Address.page(1).per(25)
            assert_equal 'Displaying <b>1</b> address', view.page_entries_info(addresses)
          end

          test 'setting the entry name option to "place"' do
            addresses = User::Address.page(1).per(25)
            assert_equal 'Displaying <b>1</b> place', view.page_entries_info(addresses, entry_name: 'place')
          end
        end

        sub_test_case 'having more than 1 but less than a page of entries' do
          setup do
            10.times { User::Address.create! }
          end

          test 'with default entry name' do
            addresses = User::Address.page(1).per(25)
            assert_equal 'Displaying <b>all 10</b> addresses', view.page_entries_info(addresses)
          end

          test 'setting the entry name option to "place"' do
            addresses = User::Address.page(1).per(25)
            assert_equal 'Displaying <b>all 10</b> places', view.page_entries_info(addresses, entry_name: 'place')
          end
        end

        sub_test_case 'having more than one page of entries' do
          setup do
            50.times { User::Address.create! }
          end

          sub_test_case 'the first page' do
            test 'with default entry name' do
              addresses = User::Address.page(1).per(25)
              assert_equal 'Displaying addresses <b>1&nbsp;-&nbsp;25</b> of <b>50</b> in total', view.page_entries_info(addresses)
            end

            test 'setting the entry name option to "place"' do
              addresses = User::Address.page(1).per(25)
              assert_equal 'Displaying places <b>1&nbsp;-&nbsp;25</b> of <b>50</b> in total', view.page_entries_info(addresses, entry_name: 'place')
            end
          end

          sub_test_case 'the next page' do
            test 'with default entry name' do
              addresses = User::Address.page(2).per(25)
              assert_equal 'Displaying addresses <b>26&nbsp;-&nbsp;50</b> of <b>50</b> in total', view.page_entries_info(addresses)
            end

            test 'setting the entry name option to "place"' do
              addresses = User::Address.page(2).per(25)
              assert_equal 'Displaying places <b>26&nbsp;-&nbsp;50</b> of <b>50</b> in total', view.page_entries_info(addresses, entry_name: 'place')
            end
          end
        end
      end

      test 'on a PaginatableArray' do
        numbers = Kaminari.paginate_array(%w{one two three}).page(1)

        assert_equal 'Displaying <b>all 3</b> entries', view.page_entries_info(numbers)
      end
    end

    sub_test_case '#rel_next_prev_link_tags' do
      setup do
        31.times {|i| User.create! name: "user#{i}"}
      end

      test 'the first page' do
        users = User.page(1).per(10)
        html = view.rel_next_prev_link_tags users, params: {controller: 'users', action: 'index'}

        assert_not_match(/rel="prev"/, html)
        assert_match(/rel="next"/, html)
        assert_match(/\?page=2/, html)
      end

      test 'the second page' do
        users = User.page(2).per(10)
        html = view.rel_next_prev_link_tags users, params: {controller: 'users', action: 'index'}

        assert_match(/rel="prev"/, html)
        assert_not_match(/\?page=1/, html)
        assert_match(/rel="next"/, html)
        assert_match(/\?page=3/, html)
      end

      test 'the last page' do
        users = User.page(4).per(10)
        html = view.rel_next_prev_link_tags users, params: {controller: 'users', action: 'index'}

        assert_match(/rel="prev"/, html)
        assert_match(/\?page=3"/, html)
        assert_not_match(/rel="next"/, html)
      end
    end

    sub_test_case '#path_to_next_page' do
      setup do
        2.times {|i| User.create! name: "user#{i}"}
      end

      test 'the first page' do
        users = User.page(1).per(1)
        assert_equal '/users?page=2', view.path_to_next_page(users, params: {controller: 'users', action: 'index'})
      end

      test 'the last page' do
        users = User.page(2).per(1)
        assert_nil view.path_to_next_page(users, params: {controller: 'users', action: 'index'})
      end
    end

    sub_test_case '#path_to_prev_page' do
      setup do
        3.times {|i| User.create! name: "user#{i}"}
      end

      test 'the first page' do
        users = User.page(1).per(1)
        assert_nil view.path_to_prev_page(users, params: {controller: 'users', action: 'index'})
      end

      test 'the second page' do
        users = User.page(2).per(1)
        assert_equal '/users', view.path_to_prev_page(users, params: {controller: 'users', action: 'index'})
      end

      test 'the last page' do
        users = User.page(3).per(1)
        assert_equal '/users?page=2', view.path_to_prev_page(users, params: {controller: 'users', action: 'index'})
      end
    end

    sub_test_case '#next_page_url' do
      setup do
        2.times {|i| User.create! name: "user#{i}"}
      end

      test 'the first page' do
        users = User.page(1).per(1)
        assert_equal 'http://test.host/users?page=2', view.next_page_url(users, params: {controller: 'users', action: 'index'})
      end

      test 'the last page' do
        users = User.page(2).per(1)
        assert_nil view.next_page_url(users, params: {controller: 'users', action: 'index'})
      end
    end

    sub_test_case '#prev_page_url' do
      setup do
        3.times {|i| User.create! name: "user#{i}"}
      end

      test 'the first page' do
        users = User.page(1).per(1)
        assert_nil view.prev_page_url(users, params: {controller: 'users', action: 'index'})
      end

      test 'the second page' do
        users = User.page(2).per(1)
        assert_equal 'http://test.host/users', view.prev_page_url(users, params: {controller: 'users', action: 'index'})
      end

      test 'the last page' do
        users = User.page(3).per(1)
        assert_equal 'http://test.host/users?page=2', view.prev_page_url(users, params: {controller: 'users', action: 'index'})
      end
    end
  end
end
