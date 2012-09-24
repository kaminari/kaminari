require 'active_support/configurable'

module Kaminari
  # Configures global settings for Kaminari
  #   Kaminari.configure do |config|
  #     config.default_per_page = 10
  #   end
  def self.configure(&block)
    yield Kaminari::Configuration
  end

  # Global settings for Kaminari
  def self.config
    Kaminari::Configuration
  end

  module Configurable
    # just for patching AS::Configurable#config_accessor
    extend ActiveSupport::Concern
    include ActiveSupport::Configurable

    included do
      class << self
        def config_accessor(*names)
          super
          names.each do |name|
            send("#{name}=",yield) if block_given?
          end
        end
      end

      def self.config_writer(*names)
        # define just the writer (copied from AS::Configurable)
        names.each do |name|
          writer, line = "def #{name}=(value); config.#{name} = value; end", __LINE__
          singleton_class.class_eval writer, __FILE__, line
          send("#{name}=",yield) if block_given?
        end
      end
    end
  end

  module Configuration #:nodoc:
    include Configurable

    CONFIG_OPTIONS = {
      :default_per_page => 25,
      :max_per_page     => nil,
      :window           => 4,
      :outer_window     => 0,
      :left             => 0,
      :right            => 0,
      :page_method_name => :page
    }

    CONFIG_OPTIONS.each do |k,v|
      config_accessor k do
        v
      end
    end

    def self.param_name
      config.param_name.respond_to?(:call) ? config.param_name.call : config.param_name
    end

    config_writer :param_name do
      :page
    end
  end
end
