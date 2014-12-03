require "spec_helper"

describe "next page partial" do

  let(:page_number) { 2 }
  let(:link_options) { {} }
  let(:locals_hash) { {
    :current_page => Kaminari::Helpers::Paginator::PageProxy.new(
      {:current_page => 2, :total_pages => 3}, page_number, nil),
    :link_options => link_options,
    :url => "next"
  } }

  [:erb, :haml, :slim].each do |template_engine|
    describe "(:#{template_engine})" do

      context "when this page is the next page" do
        let(:page_number) { 3 }
        let(:link_options) { {:remote => true} }

        it "renders the text without link" do
          render :partial => "kaminari/next_page", :handlers => [template_engine], :locals => locals_hash
          expect(rendered).to match(I18n.t('views.pagination.next'))
          rendered.should_not have_link("Next")
        end
      end

      context "when this page is not the next page" do
        let(:page_number) { 2 }

        it "renders the link to the next page" do
          render :partial => "kaminari/next_page", :handlers => [template_engine], :locals => locals_hash
          rendered.should have_link("Next", :href => "next")
        end

        context "with link_option remote=true" do
          let(:link_options) { {:remote => true} }

          it "contains data-remote" do
            render :partial => "kaminari/next_page", :handlers => [template_engine], :locals => locals_hash
            rendered.should have_xpath("//a[@data-remote='true']")
          end
        end
      end

    end
  end
end
