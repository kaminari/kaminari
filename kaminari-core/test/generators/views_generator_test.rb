# frozen_string_literal: true

require 'test_helper'

if defined?(::Rails::Railtie)
  require 'rails/generators'
  require 'generators/kaminari/views_generator'
  require 'tmpdir'

  class ViewsGeneratorDefaultThemeTest < ::Test::Unit::TestCase
    def run_generator(*args)
      Dir.mktmpdir do |dir|
        out = capture_output { Kaminari::Generators::ViewsGenerator.start(['default', *args], destination_root: dir) }.first
        yield out, Dir.glob(File.join(dir, 'app/views/kaminari/*')).map {|f| File.basename f }.sort
      end
    end

    test 'copies the erb templates' do
      run_generator do |out, files|
        assert_equal %w(_first_page.html.erb _gap.html.erb _last_page.html.erb _next_page.html.erb _page.html.erb _paginator.html.erb _prev_page.html.erb), files
        assert_not_match(/not supported/, out)
      end
    end

    test 'falls back to erb with a warning for an unsupported template engine' do
      run_generator('-e', 'tailwindcss') do |out, files|
        assert_equal 7, files.count {|f| f.end_with? '.html.erb' }
        assert_match(/template_engine: tailwindcss is not supported\. Falling back to erb\./, out)
      end
    end
  end

  class ViewsGeneratorNetworkErrorTest < ::Test::Unit::TestCase
    RATE_LIMIT_EXCEEDED = OpenURI::HTTPError.new('403 rate limit exceeded', StringIO.new)

    # Replaces a GitHubApiHelper method with the given lambda while yielding
    def stub_github_api(name, stub)
      helper = Kaminari::Generators::GitHubApiHelper
      original = helper.method(name)
      helper.define_singleton_method name, stub
      Kaminari::Generators::ViewsGenerator.instance_variable_set :@themes, nil
      yield
    ensure
      helper.define_singleton_method name, original
      Kaminari::Generators::ViewsGenerator.instance_variable_set :@themes, nil
    end

    def run_generator(*args)
      Dir.mktmpdir do |dir|
        out = capture_output { Kaminari::Generators::ViewsGenerator.start(args, destination_root: dir) }.first
        yield out, Dir.glob(File.join(dir, 'app/views/kaminari/*'))
      end
    end

    test 'the banner does not raise when the themes are not available' do
      stub_github_api(:get_files_in_master, -> { raise RATE_LIMIT_EXCEEDED }) do
        assert_match(/- default/, Kaminari::Generators::ViewsGenerator.banner)
      end
    end

    test 'the banner does not raise when the theme descriptions are not available' do
      stub_github_api(:get_files_in_master, -> { [['bootstrap4/DESCRIPTION', 'sha1'], ['bootstrap4/app/views/kaminari/_page.html.erb', 'sha2']] }) do
        stub_github_api(:get_content_for, ->(_) { raise RATE_LIMIT_EXCEEDED }) do
          assert_match(/- bootstrap4/, Kaminari::Generators::ViewsGenerator.banner)
        end
      end
    end

    test 'tells that the themes are not available' do
      stub_github_api(:get_files_in_master, -> { raise RATE_LIMIT_EXCEEDED }) do
        run_generator('bootstrap4') do |out, files|
          assert_match(/could not fetch the themes from GitHub/, out)
          assert_empty files
        end
      end
    end

    test 'tells that the templates could not be downloaded' do
      stub_github_api(:get_files_in_master, -> { [['bootstrap4/app/views/kaminari/_page.html.erb', 'sha']] }) do
        stub_github_api(:get_content_for, ->(_) { raise RATE_LIMIT_EXCEEDED }) do
          run_generator('bootstrap4') do |out, files|
            assert_match(/could not download the templates from GitHub \(403 rate limit exceeded\)/, out)
            assert_empty files
          end
        end
      end
    end
  end
end

if defined?(::Rails::Railtie) && ENV['GENERATOR_SPEC']
  class ViewsGeneratorTest < ::Test::Unit::TestCase
    test '.themes is a public class method' do
      assert Kaminari::Generators::ViewsGenerator.respond_to?(:themes),
        '`themes` must be a public class method so that `self.class.themes` works from instance methods'
    end

    test '.banner does not raise' do
      assert_nothing_raised { Kaminari::Generators::ViewsGenerator.banner }
    end
  end

  class GitHubApiHelperTest < ::Test::Unit::TestCase
    test '.get_files_in_master' do
      assert_include Kaminari::Generators::GitHubApiHelper.get_files_in_master, %w(README.md 7f712676aac6bcd912981a9189c110303a1ee266)
    end

    test '.get_content_for' do
      assert Kaminari::Generators::GitHubApiHelper.get_content_for('README.md').start_with?('# ')
    end
  end
end
