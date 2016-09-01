module Kaminari
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      desc <<DESC
Description:
    Copies Kaminari configuration file to your application's initializer directory.
DESC

      def copy_config_file
        warn_if_old_config_file_exists
        template 'kaminari_config.rb', 'config/initializers/kaminari.rb'
      end

      private

      def warn_if_old_config_file_exists
        if File.exists?('config/initializers/kaminari_config.rb')
          warn <<MESSAGE
Warning:
    You already have kaminari_config.rb file inside initializers directory.
MESSAGE
        end
    end
  end
end
