require 'kaminari/sinatra'
require 'kaminari/helpers/action_view_extension'
require 'rack/test'
require 'sinatra/test_helpers'
require 'capybara/rspec'

require 'fake_app/sinatra_app'

# keep this until https://github.com/haml/haml/issues/814 is fixed
module Haml::Helpers::XssMods
  def self.included(base)
    unless base.respond_to?(:html_escape_without_haml_xss)
      %w[html_escape find_and_preserve preserve list_of surround
         precede succeed capture_haml haml_concat haml_indent
         haml_tag escape_once].each do |name|
        base.send(:alias_method, "#{name}_without_haml_xss", name)
        base.send(:alias_method, name, "#{name}_with_haml_xss")
      end
    end
  end
end
require "haml/template"

Capybara.app = SinatraApp

module HelperMethodForHelperSpec
  module FakeEnv
    def env
      {'PATH_INFO' => '/'}
    end
  end

  def helper
    # OMG terrible object...
    ::Kaminari::Helpers::SinatraHelpers::ActionViewTemplateProxy.new(:current_params => {}, :current_path => '/', :param_name => Kaminari.config.param_name).extend(Padrino::Helpers, Kaminari::ActionViewExtension, Kaminari::Helpers::SinatraHelpers::HelperMethods, FakeEnv)
  end
end

module RenderMethodForViewSpec
  include HelperMethodForHelperSpec

  def self.included(config)
    config.after(:each) do
      @rendered = ""
    end
  end

  def view_template_proxy
    @view_template_proxy ||= helper
  end

  def render args
    @rendered = view_template_proxy.render args
  end

  def rendered
    @rendered
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Sinatra::TestHelpers
  config.include HelperMethodForHelperSpec, :example_group => {:file_path => %r(spec/helpers)}
  config.include RenderMethodForViewSpec, :example_group => {:file_path => %r(spec/views)}
  config.include Capybara::RSpecMatchers, :example_group => {:file_path => %r(spec/views)}
end

require 'nokogiri'
def last_document
  Nokogiri::HTML(last_response.body)
end
