module Kaminari
  module Generators

    class ViewsGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../../../../app/views/kaminari', __FILE__)

      class_option :template_engine, :type => :string, :aliases => '-e', :desc => 'Template engine for the views. Available options are "erb", "haml", and "slim".'

      def self.banner #:nodoc:
        <<-BANNER.chomp
rails g kaminari:views THEME [options]

    Copies all paginator partial templates to your application.
    You can choose a template THEME by specifying one from the list below:

        - default
            The default one.
            This one is used internally while you don't override the partials.
#{themes.map {|t| "        - #{t.name}\n#{t.description}"}.join("\n")}
BANNER
      end

      desc ''
      def copy_or_fetch #:nodoc:
        return copy_default_views if file_name == 'default'

        if theme = self.class.themes.detect {|t| t.name == file_name}
          if download_templates(theme).empty?
            say %Q[template_engine: #{template_engine} is not available for theme: #{file_name}]
          end
        else
          say %Q[no such theme: #{file_name}\n  avaliable themes: #{self.class.themes.map(&:name).join ", "}]
        end
      end

      private
      def self.themes
        begin
          @themes ||= GitHubApiHelper.get_files_in_master.group_by {|fn, _| fn[0...(fn.index('/') || 0)]}.delete_if {|fn, _| fn.blank?}.map do |name, files|
            Theme.new name, files
          end
        rescue SocketError
          []
        end
      end

      def download_templates(theme)
        theme.templates_for(template_engine).each do |template|
          say "      downloading #{template.name} from kaminari_themes..."
          create_file template.name, GitHubApiHelper.get_content_for("#{theme.name}/#{template.name}")
        end
      end

      def copy_default_views
        filename_pattern = File.join self.class.source_root, "*.html.#{template_engine}"
        Dir.glob(filename_pattern).map {|f| File.basename f}.each do |f|
          copy_file f, "app/views/kaminari/#{f}"
        end
      end

      def template_engine
        options[:template_engine].try(:to_s).try(:downcase) || 'erb'
      end
    end

    Template = Struct.new(:name, :sha) do
      def description?
        name == 'DESCRIPTION'
      end

      def view?
        name =~ /^app\/views\//
      end

      def engine #:nodoc:
        File.extname(name).sub /^\./, ''
      end
    end

    class Theme
      attr_accessor :name
      def initialize(name, templates) #:nodoc:
        @name, @templates = name, templates.map {|fn, sha| Template.new fn.sub(/^#{name}\//, ''), sha}
      end

      def description #:nodoc:
        file = @templates.detect(&:description?)
        return "#{' ' * 12}#{name}" unless file
        GitHubApiHelper.get_content_for("#{@name}/#{file.name}").chomp.gsub(/^/, ' ' * 12)
      end

      def templates_for(template_engine) #:nodoc:
        @templates.select {|t| t.engine == template_engine }
      end
    end

    module GitHubApiHelper
      def get_files_in_master
        master_tree_sha = open('https://api.github.com/repos/amatsuda/kaminari_themes/git/refs/heads/master') do |json|
          ActiveSupport::JSON.decode(json.read)['object']['sha']
        end
        open('https://api.github.com/repos/amatsuda/kaminari_themes/git/trees/' + master_tree_sha + '?recursive=1') do |json|
          blobs = ActiveSupport::JSON.decode(json.read)['tree'].find_all {|i| i['type'] == 'blob' }
          blobs.map do |blob|
            [blob['path'], blob['sha']]
          end
        end
      end
      module_function :get_files_in_master

      def get_content_for(path)
        open('https://api.github.com/repos/amatsuda/kaminari_themes/contents/' + path) do |json|
          Base64.decode64(ActiveSupport::JSON.decode(json.read)['content'])
        end
      end
      module_function :get_content_for
    end
  end
end
