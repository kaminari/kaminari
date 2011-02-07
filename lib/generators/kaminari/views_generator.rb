module Kaminari
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path('../../../../app/views/kaminari', __FILE__)

      class_option :template_engine, :type => :string, :aliases => '-e', :desc => 'Template engine for the views. Available options are "erb" and "haml".'

      desc 'Copies all paginator partials to your application.'
      def copy_views
        Dir.glob(filename_pattern).map {|f| File.basename f}.each do |f|
          copy_file f, "app/views/kaminari/#{f}"
        end
      end

      private
      def filename_pattern
        File.join self.class.source_root, "*.html.#{options[:template_engine] || 'erb'}"
      end
    end
  end
end
