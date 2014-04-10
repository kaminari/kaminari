require 'spec_helper'

if defined?(Rails)
  require 'rails/generators'
  require 'generators/kaminari/views_generator'

  describe Kaminari::Generators::GitHubApiHelper, :generator_spec => true do
    describe '.get_files_in_master' do
      subject { Kaminari::Generators::GitHubApiHelper.get_files_in_master }
      it { should include(["README", "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391"]) }
    end

    describe '.get_content_for' do
      subject { Kaminari::Generators::GitHubApiHelper.get_content_for("README") }
      it { should == "" }
    end
  end
end
