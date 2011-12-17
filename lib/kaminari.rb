module Kaminari
  def self.frameworks
    frameworks = []
    case
      when rails?   then frameworks << 'rails'
      when sinatra? then frameworks << 'sinatra/base'
    end
    frameworks
  end

  def self.load_framework!
    show_warning if frameworks.empty?
    frameworks.each do |framework|
      begin
        require framework
      rescue NameError => e
        raise "Failed to load framework #{framework.inspect}. Have you added it to Gemfile?"
      end
    end
  end

  def self.show_warning
    $stderr.puts <<-EOC
warning: no framework detected.
would you check out if your Gemfile appropriately configured?
---- e.g. ----
when Rails:
    gem 'rails'
    gem 'kaminari'

when Sinatra/Padrino:
    gem 'kaminari', :require => 'kaminari/sinatra'

    EOC
  end

  def self.load_kaminari!
    require 'kaminari/config'
    require 'kaminari/helpers/action_view_extension'
    require 'kaminari/helpers/paginator'
    require 'kaminari/models/page_scope_methods'
    require 'kaminari/models/configuration_methods'
  end

  def self.hook!
    load_framework!
    load_kaminari!
    require 'kaminari/hooks'
    if rails?
      require 'kaminari/railtie'
      require 'kaminari/engine'
    elsif sinatra?
      require 'kaminari/sinatra'
    else
      Kaminari::Hooks.init!
    end
  end

  def self.load!
    hook!
  end

  private
  def self.rails?
    defined?(::Rails)
  end

  def self.sinatra?
    defined?(::Sinatra)
  end
end

Kaminari.load!
