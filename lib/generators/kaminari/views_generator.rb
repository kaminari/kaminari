module Kaminari
  module Generators
    class ViewsGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../../../../app/views/kaminari', __FILE__)

      class_option :template_engine, :type => :string, :aliases => '-e', :desc => 'Template engine for the views. Available options are "erb" and "haml".'

      def self.banner #:nodoc:
        <<-BANNER.chomp
rails g kaminari:views THEME [options]

    Copies all paginator partial templates to your application.
    You can choose a template THEME by specifying one from the list below:

        default: The default one.
                 This one is used internally while you don't override the partials.
        google:  Looks googlish! (note that this is just an example...)
                 Try with this option  :window => 10, :outer_window => -1
        github:  A very simple one with only "Older" and "Newer" links.
BANNER
      end

      desc ''
      def copy_views #:nodoc:
        Dir.glob(filename_pattern).map {|f| File.basename f}.each do |f|
          copy_file File.join([template_name.presence, f].compact), "app/views/kaminari/#{f}"
        end
      end

      private
      def template_name
        (f = file_name.downcase) == 'default' ? '' : f
      end

      def filename_pattern
        File.join self.class.source_root, template_name, "*.html.#{options[:template_engine].try(:to_s).try(:downcase) || 'erb'}"
      end
    end
  end
end
