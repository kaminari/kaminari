require "spec_helper"

describe "prev page partial" do

  let(:page_number) { 2 }
  let(:link_options) { {} }
  let(:locals_hash) { {
    :current_page => Kaminari::Helpers::Paginator::PageProxy.new(
      {:current_page => 2, :total_pages => 3}, page_number, nil),
    :link_options => link_options,
    :url => "prev"
  } }

  [:erb, :haml, :slim].each do |template_engine|
    describe "(:#{template_engine})" do

      context "when this page is the prev page" do
        let(:page_number) { 1 }
        let(:link_options) { {:remote => true} }

        it "renders the text without link" do
          render :partial => "kaminari/prev_page", :handlers => [template_engine], :locals => locals_hash
          expect(rendered).to match(I18n.t('views.pagination.previous'))
          rendered.should_not have_link("Prev")
        end
      end

      context "when this page is not the prev page" do
        let(:page_number) { 2 }

        it "renders the link to the prev page" do
          render :partial => "kaminari/prev_page", :handlers => [template_engine], :locals => locals_hash
          rendered.should have_link("Prev", :href => "prev")
        end

        context "with link_option remote=true" do
          let(:link_options) { {:remote => true} }

          it "contains data-remote" do
            render :partial => "kaminari/prev_page", :handlers => [template_engine], :locals => locals_hash
            rendered.should have_xpath("//a[@data-remote='true']")
          end
        end
      end

    end
  end
end
