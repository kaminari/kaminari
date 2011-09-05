module Kaminari

  def self.framework
    case
      when defined?(::Rails) then 'rails'
      when defined?(::Padrino) then 'padrino'
      else nil
    end
  end

  def self.load_framework!
    begin
      require framework
    rescue ArgumentError => e
      raise "No framework specified!"
    rescue NameError => e
      raise "Framework not detected."
    ensure
      # ensure ORMs are loaded *before* initializing Kaminari
      begin; require 'mongoid'; rescue LoadError; end
      begin; require 'mongo_mapper'; rescue LoadError; end
      begin; require 'dm-core'; require 'dm-aggregates'; rescue LoadError; end
    end
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
    if defined?(::Rails)
      require 'kaminari/railtie'
      require 'kaminari/engine'
    elsif defined?(::Padrino)
      require 'kaminari/padrino'
    else
      Kaminari::Hooks.init!
    end
  end

  def self.load!
    hook!
  end

end

Kaminari.load!
