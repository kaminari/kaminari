# frozen_string_literal: true

require 'test_helper'

if defined? ActiveRecord
  class ActiveRecordModelExtensionTest < ActiveSupport::TestCase
    test 'Changing page_method_name' do
      begin
        Kaminari.configure {|config| config.page_method_name = :per_page_kaminari }

        model = Class.new ActiveRecord::Base

        assert_respond_to model, :per_page_kaminari
        assert_not_respond_to model, :page
      ensure
        Kaminari.configure {|config| config.page_method_name = :page }
      end
    end
  end

  class ActiveRecordExtensionTest < ActiveSupport::TestCase
    def assert_first_page(relation)
      assert_equal 25, relation.count
      assert_equal 'user001', relation.first.name
    end

    def assert_blank_page(relation)
      assert_equal 0, relation.count
    end

    class << self
      def startup
        [User, GemDefinedModel, Device].each do |m|
          1.upto(100) {|i| m.create! name: "user#{'%03d' % i}", age: (i / 10)}
        end
        super
      end

      def shutdown
        [User, GemDefinedModel, Device].each(&:delete_all)
        super
      end
    end

    [User, Admin, GemDefinedModel, Device].each do |model_class|
      sub_test_case "for #{model_class}" do
        sub_test_case '#page' do
          test 'page 1' do
            assert_first_page model_class.page(1)
          end

          test 'page 2' do
            relation = model_class.page 2

            assert_equal 25, relation.count
            assert_equal 'user026', relation.first.name
          end

          test 'page without an argument' do
            assert_first_page model_class.page
          end

          test 'page < 1' do
            assert_first_page model_class.page(0)
          end

          test 'page > max page' do
            assert_blank_page model_class.page(5)
          end

          test 'ensure #order_values is preserved' do
            relation = model_class.order('id').page 1

            assert_equal ['id'], relation.order_values.uniq
          end
        end

        sub_test_case '#per' do
          test 'page 1 per 5' do
            relation = model_class.page(1).per(5)

            assert_equal 5, relation.count
            assert_equal 'user001', relation.first.name
          end

          test 'page 1 per 5 with max_per_page < 5' do
            begin
              model_class.max_paginates_per 4
              relation = model_class.page(1).per(5)

              assert_equal 4, relation.count
            ensure
              model_class.max_paginates_per nil
            end
          end

          test 'page 1 per nil (using default)' do
            assert_equal model_class.default_per_page, model_class.page(1).per(nil).count
          end

          test 'page 1 per nil with max_per_page > default_per_page' do
            begin
              model_class.max_paginates_per(30)

              assert_equal 25, model_class.page(1).per(nil).count
            ensure
              model_class.max_paginates_per(nil)
            end
          end

          test 'page 1 per nil with max_per_page < default_per_page' do
            begin
              model_class.max_paginates_per(10)

              assert_equal 10, model_class.page(1).per(nil).count
            ensure
              model_class.max_paginates_per(nil)
            end
          end

          test 'page 1 per 0' do
            assert_equal 0, model_class.page(1).per(0).count
          end

          # I know it's a bit strange to have this here, but I couldn't find any better place for this case
          sub_test_case 'when max_per_page is given via model class, and `per` is not actually called' do
            test 'with max_per_page > default_per_page' do
              begin
                model_class.max_paginates_per(200)

                assert_equal 25, model_class.page(1).count
              ensure
                model_class.max_paginates_per(nil)
              end
            end

            test 'with max_per_page < default_per_page' do
              begin
                model_class.max_paginates_per(5)

                assert_equal 5, model_class.page(1).count
              ensure
                model_class.max_paginates_per(nil)
              end
            end
          end
        end

        sub_test_case '#max_paginates_per' do
          setup do
            model_class.max_paginates_per(10)
          end
          teardown do
            model_class.max_paginates_per(nil)
          end

          sub_test_case 'calling max_paginates_per() after per()' do
            test 'when #max_paginates_per is greater than #per' do
              assert_equal 15, model_class.page(1).per(15).max_paginates_per(20).count
            end

            test 'when #per is greater than #max_paginates_per' do
              assert_equal 20, model_class.page(1).per(30).max_paginates_per(20).count
            end

            test 'when nil is given to #per and #max_paginates_per is specified' do
              assert_equal 20, model_class.page(1).per(nil).max_paginates_per(20).count
            end
          end

          sub_test_case 'calling max_paginates_per() before per()' do
            test 'when #max_paginates_per is greater than #per' do
              assert_equal 15, model_class.page(1).max_paginates_per(20).per(15).count
            end

            test 'when #per is greater than #max_paginates_per' do
              assert_equal 20, model_class.page(1).max_paginates_per(20).per(30).count
            end

            test 'when nil is given to #per and #max_paginates_per is specified' do
              assert_equal 20, model_class.page(1).max_paginates_per(20).per(nil).count
            end
          end

          sub_test_case 'calling max_paginates_per() without per()' do
            test 'when #max_paginates_per is greater than the default per_page' do
              assert_equal 20, model_class.page(1).max_paginates_per(20).count
            end

            test 'when #max_paginates_per is less than the default per_page' do
              assert_equal 25, model_class.page(1).max_paginates_per(30).count
            end
          end
        end

        sub_test_case '#padding' do
          test 'page 1 per 5 padding 1' do
            relation = model_class.page(1).per(5).padding(1)

            assert_equal 5, relation.count
            assert_equal 'user002', relation.first.name
          end

          test 'page 1 per 5 padding "1" (as string)' do
            relation = model_class.page(1).per(5).padding('1')

            assert_equal 5, relation.count
            assert_equal 'user002', relation.first.name
          end

          test 'page 19 per 5 padding 5' do
            relation = model_class.page(19).per(5).padding(5)

            assert_equal 19, relation.current_page
            assert_equal 19, relation.total_pages
          end

          test 'Negative padding' do
            assert_raise(ArgumentError) { model_class.page(1).per(5).padding(-1) }
          end
        end

        sub_test_case '#total_pages' do
          test 'per 25 (default)' do
            assert_equal 4, model_class.page.total_pages
          end

          test 'per 7' do
            assert_equal 15, model_class.page(2).per(7).total_pages
          end

          test 'per 65536' do
            assert_equal 1, model_class.page(50).per(65536).total_pages
          end

          test 'per 0' do
            assert_raise Kaminari::ZeroPerPageOperation do
              model_class.page(50).per(0).total_pages
            end
          end

          test 'per -1 (using default)' do
            assert_equal 4, model_class.page(5).per(-1).total_pages
          end

          test 'per "String value that can not be converted into Number" (using default)' do
            assert_equal 4, model_class.page(5).per('aho').total_pages
          end

          test 'with max_pages < total pages count from database' do
            begin
              model_class.max_pages 3

              assert_equal 3, model_class.page.total_pages
            ensure
              model_class.max_pages nil
            end
          end

          test 'with max_pages > total pages count from database' do
            begin
              model_class.max_pages 11

              assert_equal 4, model_class.page.total_pages
            ensure
              model_class.max_pages nil
            end
          end

          test 'with max_pages is nil (default)' do
            model_class.max_pages nil

            assert_equal 4, model_class.page.total_pages
          end

          test 'with per(nil) using default' do
            assert_equal 4, model_class.page.per(nil).total_pages
          end
        end

        sub_test_case '#current_page' do
          test 'any page, per 0' do
            assert_raise Kaminari::ZeroPerPageOperation do
              model_class.page.per(0).current_page
            end
          end

          test 'page 1' do
            assert_equal 1, model_class.page.current_page
          end

          test 'page 2' do
            assert_equal 2, model_class.page(2).per(3).current_page
          end
        end

        sub_test_case '#current_per_page' do
          test 'per 0' do
            assert_equal 0, model_class.page.per(0).current_per_page
          end

          test 'no per specified' do
            assert_equal model_class.default_per_page, model_class.page.current_per_page
          end

          test 'per specified as 42' do
            assert_equal 42, model_class.page.per(42).current_per_page
          end
        end

        sub_test_case '#next_page' do
          test 'page 1' do
            assert_equal 2, model_class.page.next_page
          end

          test 'page 5' do
            assert_nil model_class.page(5).next_page
          end
        end

        sub_test_case '#prev_page' do
          test 'page 1' do
            assert_nil model_class.page.prev_page
          end

          test 'page 3' do
            assert_equal 2, model_class.page(3).prev_page
          end

          test 'page 5' do
            assert_nil model_class.page(5).prev_page
          end
        end

        sub_test_case '#first_page?' do
          test 'on first page' do
            assert_true model_class.page(1).per(10).first_page?
          end

          test 'not on first page' do
            assert_false model_class.page(5).per(10).first_page?
          end
        end

        sub_test_case '#last_page?' do
          test 'on last page' do
            assert_true model_class.page(10).per(10).last_page?
          end

          test 'within range' do
            assert_false model_class.page(1).per(10).last_page?
          end

          test 'out of range' do
            assert_false model_class.page(11).per(10).last_page?
          end
        end

        sub_test_case '#out_of_range?' do
          test 'on last page' do
            assert_false model_class.page(10).per(10).out_of_range?
          end

          test 'within range' do
            assert_false model_class.page(1).per(10).out_of_range?
          end

          test 'out of range' do
            assert_true model_class.page(11).per(10).out_of_range?
          end
        end

        sub_test_case '#count' do
          test 'page 1' do
            assert_equal 25, model_class.page.count
          end

          test 'page 2' do
            assert_equal 25, model_class.page(2).count
          end
        end

        test 'chained with .group' do
          relation = model_class.group('age').page(2).per 5
          # 0..10
          assert_equal 11, relation.total_count
          assert_equal 3, relation.total_pages
        end

        test 'activerecord descendants' do
          assert_not_equal 0, ActiveRecord::Base.descendants.length
        end
      end
    end
  end
end
