require "spec_helper"

describe "first page partial" do

  let(:page_number) { 2 }
  let(:html) { {} }
  let(:locals_hash) { {
    :current_page => Kaminari::Helpers::Paginator::PageProxy.new(
      {:current_page => 2, :total_pages => 3}, page_number, nil),
    :html => html,
    :url => "first"
  } }

  [:erb, :haml, :slim].each do |template_engine|
    describe "(:#{template_engine})" do

      context "when this page is the first page" do
        let(:page_number) { 1 }
        let(:html) { {:remote => true} }

        it "renders the text without link" do
          render :partial => "kaminari/first_page", :handlers => [template_engine], :locals => locals_hash
          expect(rendered).to match(I18n.t('views.pagination.first'))
          rendered.should_not have_link("First")
        end
      end

      context "when this page is not the first page" do
        let(:page_number) { 2 }

        it "renders the link to the first page" do
          render :partial => "kaminari/first_page", :handlers => [template_engine], :locals => locals_hash
          rendered.should have_link("First", :href => "first")
        end

        context "with link_option remote=true" do
          let(:html) { {:remote => true} }

          it "contains data-remote" do
            render :partial => "kaminari/first_page", :handlers => [template_engine], :locals => locals_hash
            rendered.should have_xpath("//a[@data-remote='true']")
          end
        end
      end

    end
  end
end
