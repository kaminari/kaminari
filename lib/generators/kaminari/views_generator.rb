module Kaminari
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path('../../../../app/views', __FILE__)

      desc 'Copies all paginator partials to your application.'
      def copy_views
        directory 'kaminari', 'app/views/kaminari'
      end
    end
  end
end
