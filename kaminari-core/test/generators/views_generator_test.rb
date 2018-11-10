# frozen_string_literal: true

require 'test_helper'

if defined?(::Rails::Railtie) && ENV['GENERATOR_SPEC']
  require 'rails/generators'
  require 'generators/kaminari/views_generator'

  class GitHubApiHelperTest < ::Test::Unit::TestCase
    test '.get_files_in_master' do
      assert_include Kaminari::Generators::GitHubApiHelper.get_files_in_master, %w(README.md 7f712676aac6bcd912981a9189c110303a1ee266)
    end

    test '.get_content_for' do
      assert Kaminari::Generators::GitHubApiHelper.get_content_for('README.md').start_with?('# ')
    end
  end
end
