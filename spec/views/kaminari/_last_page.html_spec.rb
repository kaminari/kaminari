require "spec_helper"

describe "last page partial" do

  let(:page_number) { 2 }
  let(:html) { {} }
  let(:locals_hash) { {
    :current_page => Kaminari::Helpers::Paginator::PageProxy.new(
      {:current_page => 2, :total_pages => 3}, page_number, nil),
    :html => html,
    :url => "last"
  } }

  [:erb, :haml, :slim].each do |template_engine|
    describe "(:#{template_engine})" do

      context "when this page is the last page" do
        let(:page_number) { 3 }
        let(:html) { {:remote => true} }

        it "renders the text without link" do
          render :partial => "kaminari/last_page", :handlers => [template_engine], :locals => locals_hash
          expect(rendered).to match(I18n.t('views.pagination.last'))
          rendered.should_not have_link("Last")
        end
      end

      context "when this page is not the last page" do
        let(:page_number) { 2 }

        it "renders the link to the last page" do
          render :partial => "kaminari/last_page", :handlers => [template_engine], :locals => locals_hash
          rendered.should have_link("Last", :href => "last")
        end

        context "with link_option remote=true" do
          let(:html) { {:remote => true} }

          it "contains data-remote" do
            render :partial => "kaminari/last_page", :handlers => [template_engine], :locals => locals_hash
            rendered.should have_xpath("//a[@data-remote='true']")
          end
        end
      end

    end
  end
end
