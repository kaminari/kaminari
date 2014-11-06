require 'spec_helper'
include Kaminari::Helpers

describe 'Kaminari::Helpers::Paginator' do
  let :template do
    stub(r = Object.new) do
      render.with_any_args
      params { {} }
      options { {} }
      url_for {|h| "/foo?page=#{h[:page]}"}
      link_to { "<a href='#'>link</a>" }
    end
    r
  end

  describe '#method_missing' do
    let(:paginator) { Paginator.new(template, :params => {}) }

    before do
      Paginator.remove_possible_method(:link_to)
    end

    it 'delegates view helper methods to template' do
      paginator.link_to("link", "#").should == "<a href='#'>link</a>"
    end

    it 'defines method in class' do
      expect { paginator.link_to('link', '#') }.to change {
        paginator.class.instance_methods.include?(:link_to)
      }.from(false).to(true)
    end
  end

  describe '#respond_to?' do
    it 'returns true for delegated methods' do
      expect { Paginator.new(template).respond_to?(:url_for) }.to be_true
    end
  end

  describe '#params' do
    before do
      @paginator = Paginator.new(template, :params => {:controller => 'foo', :action => 'bar'})
    end
    subject { @paginator.page_tag(template).instance_variable_get('@params') }
    it { should == {:controller => 'foo', :action => 'bar'} }

    context "when params has form params" do
      before do
        stub(template).params do
          {
            :authenticity_token => "token",
            :commit => "submit",
            :utf8 => "true",
            :_method => "patch"
          }
        end
      end

      it { should == {:controller => 'foo', :action => 'bar'} }
    end
  end

  describe '#param_name' do
    before do
      @paginator = Paginator.new(template, :param_name => :pagina)
    end
    subject { @paginator.page_tag(template).instance_variable_get('@param_name') }
    it { should == :pagina }
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
