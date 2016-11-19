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
    paginator = Paginator.new(template, :params => {})
    assert_equal "<a href='#'>link</a>", paginator.link_to('link', '#')
  end

  sub_test_case '#params' do
    setup do
      @paginator = Paginator.new(template, :params => {:controller => 'foo', :action => 'bar'})
    end

    test 'when params has no form params' do
      assert_equal({'controller' => 'foo', 'action' => 'bar'}, @paginator.page_tag(template).instance_variable_get('@params'))
    end

    test 'when params has form params' do
      stub(template).params do
        {:authenticity_token => 'token', :commit => 'submit', :utf8 => 'true', :_method => 'patch'}
      end

      assert_equal({'controller' => 'foo', 'action' => 'bar'}, @paginator.page_tag(template).instance_variable_get('@params'))
    end
  end

  test '#param_name' do
    paginator = Paginator.new(template, :param_name => :pagina)
    assert_equal :pagina, paginator.page_tag(template).instance_variable_get('@param_name')
  end

  #TODO test somehow...
#   describe '#tagify_links' do
#     def tags_with(options)
#       PaginationRenderer.new(template, options).tagify_links
#     end

#     context '1 page in total' do
#       subject { tags_with :total_pages => 1, :current_page => 1 }
#       it { should have(0).tags }
#     end

#     context '10 pages in total' do
#       context 'first page' do
#         subject { tags_with :total_pages => 10, :current_page => 1 }
#         it { should_not contain_tag PrevLink }
#         it { should contain_tag PrevSpan }
#         it { should contain_tag CurrentPage }
#         it { should_not contain_tag FirstPageLink }
#         it { should contain_tag LastPageLink }
#         it { should contain_tag PageLink }
#         it { should contain_tag NextLink }
#         it { should_not contain_tag NextSpan }
#         it { should contain_tag TruncatedSpan }
#       end

#       context 'second page' do
#         subject { tags_with :total_pages => 10, :current_page => 2 }
#         it { should contain_tag PrevLink }
#         it { should_not contain_tag PrevSpan }
#         it { should contain_tag CurrentPage }
#         it { should contain_tag FirstPageLink }
#         it { should contain_tag LastPageLink }
#         it { should contain_tag PageLink }
#         it { should contain_tag NextLink }
#         it { should_not contain_tag NextSpan }
#         it { should contain_tag TruncatedSpan }
#       end

#       context 'third page' do
#         subject { tags_with :total_pages => 10, :current_page => 3 }
#         it { should contain_tag PrevLink }
#         it { should_not contain_tag PrevSpan }
#         it { should contain_tag CurrentPage }
#         it { should contain_tag FirstPageLink }
#         it { should contain_tag LastPageLink }
#         it { should contain_tag PageLink }
#         it { should contain_tag NextLink }
#         it { should_not contain_tag NextSpan }
#         it { should contain_tag TruncatedSpan }
#       end

#       context 'fourth page(no truncation)' do
#         subject { tags_with :total_pages => 10, :current_page => 4 }
#         it { should contain_tag PrevLink }
#         it { should_not contain_tag PrevSpan }
#         it { should contain_tag CurrentPage }
#         it { should contain_tag FirstPageLink }
#         it { should contain_tag LastPageLink }
#         it { should contain_tag PageLink }
#         it { should contain_tag NextLink }
#         it { should_not contain_tag NextSpan }
#         it { should_not contain_tag TruncatedSpan }
#       end

#       context 'seventh page(no truncation)' do
#         subject { tags_with :total_pages => 10, :current_page => 7 }
#         it { should contain_tag PrevLink }
#         it { should_not contain_tag PrevSpan }
#         it { should contain_tag CurrentPage }
#         it { should contain_tag FirstPageLink }
#         it { should contain_tag LastPageLink }
#         it { should contain_tag PageLink }
#         it { should contain_tag NextLink }
#         it { should_not contain_tag NextSpan }
#         it { should_not contain_tag TruncatedSpan }
#       end

#       context 'eighth page' do
#         subject { tags_with :total_pages => 10, :current_page => 8 }
#         it { should contain_tag PrevLink }
#         it { should_not contain_tag PrevSpan }
#         it { should contain_tag CurrentPage }
#         it { should contain_tag FirstPageLink }
#         it { should contain_tag LastPageLink }
#         it { should contain_tag PageLink }
#         it { should contain_tag NextLink }
#         it { should_not contain_tag NextSpan }
#         it { should contain_tag TruncatedSpan }
#       end

#       context 'last page' do
#         subject { tags_with :total_pages => 10, :current_page => 10 }
#         it { should contain_tag PrevLink }
#         it { should_not contain_tag PrevSpan }
#         it { should contain_tag CurrentPage }
#         it { should contain_tag FirstPageLink }
#         it { should_not contain_tag LastPageLink }
#         it { should contain_tag PageLink }
#         it { should_not contain_tag NextLink }
#         it { should contain_tag NextSpan }
#         it { should contain_tag TruncatedSpan }
#       end
#     end
#   end
end
