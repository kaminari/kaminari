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
