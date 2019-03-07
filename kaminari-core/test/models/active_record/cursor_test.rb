# frozen_string_literal: true

require 'test_helper'

if defined? ActiveRecord
  class ActiveRecordExtensionTest < ActiveSupport::TestCase


    def assert_first_page(relation)
      assert_equal 25, relation.count
      assert_equal 'user001', relation.first.name
    end

    def assert_blank_page(relation)
      assert_equal 0, relation.count
    end

    [User, Admin, GemDefinedModel, Device, Post].each do |model_class|
      sub_test_case "for #{model_class}" do
        setup do
          model_class.delete_all
          if model_class == Post
            1.upto(100) do |i|
              post = Post.create! name: "user#{'%03d' % i}", age: (i / 10), created_at: (100-i).days.ago
            end
          else
            1.upto(100) {|i| model_class.create! name: "user#{'%03d' % i}", age: (i / 10)}
          end

        end

        teardown do
          model_class.delete_all
        end

        sub_test_case '#before' do
          test 'cursor_page with before' do
            record = model_class.find_by(name: 'user030')
            relation = model_class.before(record.id)
            assert_equal 25, relation.count
            assert_equal 'user029', relation.first.name
            assert_equal 'user005', relation.last.name
          end

          test 'cursor_page with before out of range' do
            relation = model_class.before(0)
            assert_blank_page(relation)
          end
        end

        sub_test_case '#after' do
          test 'cursor_page with after' do
            record = model_class.find_by!(name: 'user025')
            relation = model_class.after(record.id)
            assert_equal 25, relation.count
            assert_equal 'user026', relation.first.name
            assert_equal 'user050', relation.last.name
          end

          test 'cursor_page with after out of range' do
            record = model_class.find_by!(name: 'user100')
            relation = model_class.after(record.id)
            assert_blank_page(relation)
          end
        end

        sub_test_case '#cursor_limit' do
          test 'before with cursor_limit 5' do
            record = model_class.find_by(name: 'user030')
            relation = model_class.before(record.id).cursor_limit(5)
            assert_equal 5, relation.count
            assert_equal 'user029', relation.first.name
            assert_equal 'user025', relation.last.name
          end

          test 'after with cursor_limit 5' do
            record = model_class.find_by(name: 'user030')
            relation = model_class.after(record.id).cursor_limit(5)
            assert_equal 5, relation.count
            assert_equal 'user031', relation.first.name
            assert_equal 'user035', relation.last.name
          end

          test 'cursor_limit < 5' do
            begin
              model_class.max_cursor_limit 4
              record = model_class.find_by(name: 'user030')
              relation = model_class.after(record.id).cursor_limit(5)

              assert_equal 4, relation.count
            ensure
              model_class.max_cursor_limit nil
            end
          end
        end
      end
    end


  end
end
