# frozen_string_literal: true
require 'spec_helper'

if defined?(::Rails::Railtie)
  require 'rails/generators'
  require 'generators/kaminari/views_generator'

  describe Kaminari::Generators::GitHubApiHelper, :generator_spec => true do
    describe '.get_files_in_master' do
      subject { Kaminari::Generators::GitHubApiHelper.get_files_in_master }
      it { should include %w(README.md 7f712676aac6bcd912981a9189c110303a1ee266) }
    end

    describe '.get_content_for' do
      subject { Kaminari::Generators::GitHubApiHelper.get_content_for('README.md') }
      it { should start_with '# ' }
    end
  end
end
