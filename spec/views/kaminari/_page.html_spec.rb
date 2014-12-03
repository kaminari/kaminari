require "spec_helper"

describe "page partial" do

  let(:page_number) { 2 }
  let(:link_options) { {} }
  let(:locals_hash) { {
    :page => Kaminari::Helpers::Paginator::PageProxy.new(
      {:current_page => 2, :total_pages => 3}, page_number, nil),
    :link_options => link_options,
    :url => "prev"
  } }

  [:erb, :haml, :slim].each do |template_engine|
    describe "(:#{template_engine})" do

      context "when this page is the current page" do
        let(:page_number) { 2 }
        let(:link_options) { {:remote => true} }

        it "renders the text without link" do
          render :partial => "kaminari/page", :handlers => [template_engine], :locals => locals_hash
          expect(rendered).to match(/>\s*2\s*</)
          rendered.should_not have_link("2")
        end
      end

      context "when this page is not the current page" do
        let(:page_number) { 3 }

        it "renders the link to the given page" do
          render :partial => "kaminari/page", :handlers => [template_engine], :locals => locals_hash
          rendered.should have_link("3", :href => "prev")
        end

        context "with link_option remote=true" do
          let(:link_options) { {:remote => true} }

          it "contains data-remote" do
            render :partial => "kaminari/page", :handlers => [template_engine], :locals => locals_hash
            rendered.should have_xpath("//a[@data-remote='true']")
          end
        end
      end

    end
  end
end
