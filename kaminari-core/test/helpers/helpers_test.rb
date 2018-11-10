# frozen_string_literal: true

require 'test_helper'

class PaginatorHelperTest < ActiveSupport::TestCase
  include Kaminari::Helpers

  def template
    stub(r = Object.new) do
      render.with_any_args
      params { {} }
      options { {} }
      url_for {|h| "/foo?page=#{h[:page]}"}
      link_to { "<a href='#'>link</a>" }
      output_buffer { defined?(ActionView) ? ::ActionView::OutputBuffer.new : ::ActiveSupport::SafeBuffer.new }
    end
    r
  end

  test 'view helper methods delegated to template' do
    paginator = Paginator.new(template, params: {})
    assert_equal "<a href='#'>link</a>", paginator.link_to('link', '#')
  end

  sub_test_case '#params' do
    setup do
      @paginator = Paginator.new(template, params: {controller: 'foo', action: 'bar'})
    end

    test 'when params has no form params' do
      assert_equal({'controller' => 'foo', 'action' => 'bar'}, @paginator.page_tag(template).instance_variable_get('@params'))
    end

    test 'when params has form params' do
      stub(template).params do
        {authenticity_token: 'token', commit: 'submit', utf8: 'true', _method: 'patch'}
      end

      assert_equal({'controller' => 'foo', 'action' => 'bar'}, @paginator.page_tag(template).instance_variable_get('@params'))
    end
  end

  test '#param_name' do
    paginator = Paginator.new(template, param_name: :pagina)
    assert_equal :pagina, paginator.page_tag(template).instance_variable_get('@param_name')
  end
end
