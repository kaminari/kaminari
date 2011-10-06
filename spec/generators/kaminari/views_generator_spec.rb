require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/kaminari/views_generator'

describe Kaminari::Generators::ViewsGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../tmp", __FILE__)

  before { prepare_destination }










  describe 'themes from github' do
    let(:themes_json) { {"blobs"=>{"google/app/views/kaminari/_next_page.html.haml"=>"google-haml-next-page-sha",
                                   "google/app/views/kaminari/_prev_page.html.haml"=>"google-haml-prev-page-sha",
                                   "google/app/views/kaminari/_page.html.haml"=>     "google-haml-page-sha",
                                   "google/app/views/kaminari/_paginator.html.haml"=>"google-haml-paginator-sha",
                                   "google/app/views/kaminari/_next_page.html.haml"=>"google-haml-next-page-sha",
                                   "google/app/views/kaminari/_prev_page.html.haml"=>"google-haml-prev-page-sha",
                                   "google/app/views/kaminari/_page.html.haml"=>     "google-haml-page-sha",
                                   "google/app/views/kaminari/_paginator.html.haml"=>"google-haml-paginator-sha",
                                   "google/DESCRIPTION"=>                            "google-description-sha",
                                   "github/app/views/kaminari/_next_page.html.haml"=>"github-haml-next-page-sha",
                                   "github/app/views/kaminari/_prev_page.html.haml"=>"github-haml-prev-page-sha",
                                   "github/app/views/kaminari/_paginator.html.haml"=>"github-haml-paginator-sha",
                                   "github/app/views/kaminari/_next_page.html.haml"=>"github-haml-next-page-sha",
                                   "github/app/views/kaminari/_prev_page.html.haml"=>"github-haml-prev-page-sha",
                                   "github/app/views/kaminari/_paginator.html.haml"=>"github-haml-paginator-sha",
                                   "README"=>                                        "github-readme-sha",
                                   "github/DESCRIPTION"=>                            "github-description-sha"}
                        }.to_json
    }
    describe 'haml by default' do
      let(:next_page_theme) { '<%= "haml: next_page theme" %>' }
      let(:prev_page_theme) { '<%= "haml: prev_page theme" %>' }
      let(:paginator_theme) { '<%= "haml: paginator theme" %>' }
      before do
        stub_request(:get, "http://github.com/api/v2/json/blob/all/amatsuda/kaminari_themes/master").
          with(:headers => {'Accept'=>'*/*'}).
          to_return(:status => 200, :body => themes_json, :headers => {})
        stub_request(:get, "http://github.com/api/v2/json/blob/show/amatsuda/kaminari_themes/github-haml-next-page-sha").
          with(:headers => {'Accept'=>'*/*'}).
          to_return(:status => 200, :body => next_page_theme, :headers => {})
        stub_request(:get, "http://github.com/api/v2/json/blob/show/amatsuda/kaminari_themes/github-haml-prev-page-sha").
          with(:headers => {'Accept'=>'*/*'}).
          to_return(:status => 200, :body => prev_page_theme, :headers => {})
        stub_request(:get, "http://github.com/api/v2/json/blob/show/amatsuda/kaminari_themes/github-haml-paginator-sha").
          with(:headers => {'Accept'=>'*/*'}).
          to_return(:status => 200, :body => paginator_theme, :headers => {})

        run_generator %w(github --template_engine haml)
      end

      describe 'app/views/kaminari/_next_page.html.haml' do
        subject { file('app/views/kaminari/_next_page.html.haml') }
        it { should exist }
        it { should contain next_page_theme }
      end

      describe 'app/views/kaminari/_prev_page.html.haml' do
        subject { file('app/views/kaminari/_prev_page.html.haml') }
        it { should exist }
        it { should contain prev_page_theme }
      end

      describe 'app/views/kaminari/_paginator.html.haml' do
        subject { file('app/views/kaminari/_paginator.html.haml') }
        it { should exist }
        it { should contain paginator_theme }
      end
    end
    describe 'haml when specified' do
      let(:next_page_theme) { '== #{HAML}: next_page theme' }
      let(:prev_page_theme) { '== #{HAML}: prev_page theme' }
      let(:paginator_theme) { '== #{HAML}: paginator theme' }
      before do
        stub_request(:get, "http://github.com/api/v2/json/blob/all/amatsuda/kaminari_themes/master").
          with(:headers => {'Accept'=>'*/*'}).
          to_return(:status => 200, :body => themes_json, :headers => {})
        stub_request(:get, "http://github.com/api/v2/json/blob/show/amatsuda/kaminari_themes/github-haml-next-page-sha").
          with(:headers => {'Accept'=>'*/*'}).
          to_return(:status => 200, :body => next_page_theme, :headers => {})
        stub_request(:get, "http://github.com/api/v2/json/blob/show/amatsuda/kaminari_themes/github-haml-prev-page-sha").
          with(:headers => {'Accept'=>'*/*'}).
          to_return(:status => 200, :body => prev_page_theme, :headers => {})
        stub_request(:get, "http://github.com/api/v2/json/blob/show/amatsuda/kaminari_themes/github-haml-paginator-sha").
          with(:headers => {'Accept'=>'*/*'}).
          to_return(:status => 200, :body => paginator_theme, :headers => {})

        run_generator %w(github -e haml)
      end

      describe 'app/views/kaminari/_next_page.html.haml' do
        subject { file('app/views/kaminari/_next_page.html.haml') }
        it { should exist }
        it { should contain next_page_theme }
      end

      describe 'app/views/kaminari/_prev_page.html.haml' do
        subject { file('app/views/kaminari/_prev_page.html.haml') }
        it { should exist }
        it { should contain prev_page_theme }
      end

      describe 'app/views/kaminari/_paginator.html.haml' do
        subject { file('app/views/kaminari/_paginator.html.haml') }
        it { should exist }
        it { should contain paginator_theme }
      end
    end

  end
end
