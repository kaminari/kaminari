# frozen_string_literal: true
require 'spec_helper'

describe 'Kaminari::ActionViewExtension', :if => defined?(::Rails::Railtie) && defined?(::ActionView) do
  before do
    helper.output_buffer = ::ActionView::OutputBuffer.new
  end
  describe '#paginate' do
    before do
      50.times {|i| User.create! :name => "user#{i}"}
      @users = User.page(1)
    end

    subject { helper.paginate @users, :params => {:controller => 'users', :action => 'index'} }
    it { should be_a String }

    context 'escaping the pagination for javascript' do
      it 'should escape for javascript' do
        -> { helper.escape_javascript(helper.paginate @users, :params => {:controller => 'users', :action => 'index'}) }.should_not raise_error
      end
    end

    context 'accepts :theme option' do
      before { helper.controller.append_view_path File.join(Gem.loaded_specs['kaminari-core'].gem_dir, 'spec/fake_app/views') }
      after { helper.controller.view_paths.pop }
      subject { helper.paginate @users, :theme => "bootstrap", :params => {:controller => 'users', :action => 'index'} }
      it { should match(/bootstrap-paginator/) }
      it { should match(/bootstrap-page-link/) }
    end

    context 'accepts :views_prefix option' do
      before { helper.controller.append_view_path File.join(Gem.loaded_specs['kaminari-core'].gem_dir, 'spec/fake_app/views') }
      after { helper.controller.view_paths.pop }
      subject { helper.paginate @users, :views_prefix => "alternative/", :params => {:controller => 'users', :action => 'index'} }
      it { should eq("  <b>1</b>\n") }
    end

    context 'accepts :paginator_class option' do
      let(:custom_paginator) do
        Class.new(Kaminari::Helpers::Paginator) do
          def to_s
            "CUSTOM PAGINATION"
          end
        end
      end

      subject { helper.paginate @users, :paginator_class => custom_paginator, :params => {:controller => 'users', :action => 'index'} }
      it { should eq("CUSTOM PAGINATION") }
    end

    context "total_pages: 3" do
      subject { helper.paginate @users, :total_pages => 3, :params => {:controller => 'users', :action => 'index'} }
      it { should match(/<a href="\/users\?page=3">Last/) }
    end

    context "page: 20 (out of range)" do
      before  { @users = User.page(20) }
      subject { helper.paginate @users, :params => {:controller => 'users', :action => 'index'} }
      it { should_not match(/Last/) }
      it { should_not match(/Next/) }
    end
  end

  describe '#link_to_previous_page' do
    before do
      60.times {|i| User.create! :name => "user#{i}"}
    end

    context 'having previous pages' do
      before do
        @users = User.page(3)
      end

      context 'the default behaviour' do
        subject { helper.link_to_previous_page @users, 'Previous', :params => {:controller => 'users', :action => 'index'} }
        it { should match(/page=2/) }
        it { should match(/rel="prev"/) }
      end

      context 'overriding rel=' do
        subject { helper.link_to_previous_page @users, 'Previous', :rel => 'external', :params => {:controller => 'users', :action => 'index'} }
        it { should match(/rel="external"/) }
      end

      context 'with params' do
        before do
          helper.params[:status] = "active"
        end

        subject { helper.link_to_previous_page @users, 'Previous', :params => {:controller => 'users', :action => 'index'} }
        it { should match(/status=active/) }
      end
    end

    context 'the first page' do
      before do
        @users = User.page(1)
      end

      subject { helper.link_to_previous_page @users, 'Previous', :params => {:controller => 'users', :action => 'index'} }
      it { should_not be }
    end

    context 'out of range' do
      before { @users = User.page(5) }

      subject { helper.link_to_next_page @users, 'More', :params => {:controller => 'users', :action => 'index'} }
      it { should_not be }
    end
  end

  describe '#link_to_next_page' do
    before do
      50.times {|i| User.create! :name => "user#{i}"}
    end

    context 'having more page' do
      before do
        @users = User.page(1)
      end

      context 'the default behaviour' do
        subject { helper.link_to_next_page @users, 'More', :params => {:controller => 'users', :action => 'index'} }
        it { should match(/page=2/) }
        it { should match(/rel="next"/) }
      end

      context 'overriding rel=' do
        subject { helper.link_to_next_page @users, 'More', :rel => 'external', :params => {:controller => 'users', :action => 'index'} }
        it { should match(/rel="external"/) }
      end

      context 'with params' do
        before do
          helper.params[:status] = "active"
        end

        subject { helper.link_to_next_page @users, 'More', :params => {:controller => 'users', :action => 'index'} }
        it { should match(/status=active/) }
      end
    end

    context 'the last page' do
      before do
        @users = User.page(2)
      end

      subject { helper.link_to_next_page @users, 'More', :params => {:controller => 'users', :action => 'index'} }
      it { should_not be }
    end

    context 'out of range' do
      before { @users = User.page(5) }

      subject { helper.link_to_next_page @users, 'More', :params => {:controller => 'users', :action => 'index'} }
      it { should_not be }
    end
  end

  describe '#page_entries_info' do
    context 'on a model without namespace' do
      before do
        @users = User.page(1).per(25)
      end

      context 'having no entries' do
        subject { helper.page_entries_info @users, :params => {:controller => 'users', :action => 'index'} }
        it      { should == 'No users found' }

        context 'setting the entry name option to "member"' do
          subject { helper.page_entries_info @users, :entry_name => 'member', :params => {:controller => 'users', :action => 'index'} }
          it      { should == 'No members found' }
        end
      end

      context 'having 1 entry' do
        before do
          User.create! :name => 'user1'
          @users = User.page(1).per(25)
        end

        subject { helper.page_entries_info @users, :params => {:controller => 'users', :action => 'index'} }
        it      { should == 'Displaying <b>1</b> user' }

        context 'setting the entry name option to "member"' do
          subject { helper.page_entries_info @users, :entry_name => 'member', :params => {:controller => 'users', :action => 'index'} }
          it      { should == 'Displaying <b>1</b> member' }
        end
      end

      context 'having more than 1 but less than a page of entries' do
        before do
          10.times {|i| User.create! :name => "user#{i}"}
          @users = User.page(1).per(25)
        end

        subject { helper.page_entries_info @users, :params => {:controller => 'users', :action => 'index'} }
        it      { should == 'Displaying <b>all 10</b> users' }

        context 'setting the entry name option to "member"' do
          subject { helper.page_entries_info @users, :entry_name => 'member', :params => {:controller => 'users', :action => 'index'} }
          it      { should == 'Displaying <b>all 10</b> members' }
        end
      end

      context 'having more than one page of entries' do
        before do
          50.times {|i| User.create! :name => "user#{i}"}
        end

        describe 'the first page' do
          before do
            @users = User.page(1).per(25)
          end

          subject { helper.page_entries_info @users, :params => {:controller => 'users', :action => 'index'} }
          it      { should == 'Displaying users <b>1&nbsp;-&nbsp;25</b> of <b>50</b> in total' }

          context 'setting the entry name option to "member"' do
            subject { helper.page_entries_info @users, :entry_name => 'member', :params => {:controller => 'users', :action => 'index'} }
            it      { should == 'Displaying members <b>1&nbsp;-&nbsp;25</b> of <b>50</b> in total' }
          end
        end

        describe 'the next page' do
          before do
            @users = User.page(2).per(25)
          end

          subject { helper.page_entries_info @users, :params => {:controller => 'users', :action => 'index'} }
          it      { should == 'Displaying users <b>26&nbsp;-&nbsp;50</b> of <b>50</b> in total' }

          context 'setting the entry name option to "member"' do
            subject { helper.page_entries_info @users, :entry_name => 'member', :params => {:controller => 'users', :action => 'index'} }
            it      { should == 'Displaying members <b>26&nbsp;-&nbsp;50</b> of <b>50</b> in total' }
          end
        end

        describe 'the last page' do
          before do
            User.max_pages_per 4
            @users = User.page(4).per(10)
          end

          after { User.max_pages_per nil }

          subject { helper.page_entries_info @users, :params => {:controller => 'users', :action => 'index'} }
          it      { should == 'Displaying users <b>31&nbsp;-&nbsp;40</b> of <b>50</b> in total' }
        end
      end
    end

    context 'I18n' do
      before do
        50.times {|i| User.create! :name => "user#{i}"}
        @users = User.page(1).per(25)
        I18n.backend.store_translations(:en, User.i18n_scope => { :models => { :user => { :one => "person", :other => "people" } } })
      end

      after do
        I18n.backend.reload!
      end

      context 'page_entries_info translates entry' do
        subject { helper.page_entries_info @users, :params => {:controller => 'users', :action => 'index'} }
        it      { should == 'Displaying people <b>1&nbsp;-&nbsp;25</b> of <b>50</b> in total' }
      end
    end
    context 'on a model with namespace' do
      before do
        @addresses = User::Address.page(1).per(25)
      end

      context 'having no entries' do
        subject { helper.page_entries_info @addresses, :params => {:controller => 'addresses', :action => 'index'} }
        it      { should == 'No addresses found' }
      end

      context 'having 1 entry' do
        before do
          User::Address.create!
          @addresses = User::Address.page(1).per(25)
        end

        subject { helper.page_entries_info @addresses, :params => {:controller => 'addresses', :action => 'index'} }
        it      { should == 'Displaying <b>1</b> address' }

        context 'setting the entry name option to "place"' do
          subject { helper.page_entries_info @addresses, :entry_name => 'place', :params => {:controller => 'addresses', :action => 'index'} }
          it      { should == 'Displaying <b>1</b> place' }
        end
      end

      context 'having more than 1 but less than a page of entries' do
        before do
          10.times { User::Address.create! }
          @addresses = User::Address.page(1).per(25)
        end

        subject { helper.page_entries_info @addresses, :params => {:controller => 'addresses', :action => 'index'} }
        it      { should == 'Displaying <b>all 10</b> addresses' }

        context 'setting the entry name option to "place"' do
          subject { helper.page_entries_info @addresses, :entry_name => 'place', :params => {:controller => 'addresses', :action => 'index'} }
          it      { should == 'Displaying <b>all 10</b> places' }
        end
      end

      context 'having more than one page of entries' do
        before do
          50.times { User::Address.create! }
        end

        describe 'the first page' do
          before do
            @addresses = User::Address.page(1).per(25)
          end

          subject { helper.page_entries_info @addresses, :params => {:controller => 'addresses', :action => 'index'} }
          it      { should == 'Displaying addresses <b>1&nbsp;-&nbsp;25</b> of <b>50</b> in total' }

          context 'setting the entry name option to "place"' do
            subject { helper.page_entries_info @addresses, :entry_name => 'place', :params => {:controller => 'addresses', :action => 'index'} }
            it      { should == 'Displaying places <b>1&nbsp;-&nbsp;25</b> of <b>50</b> in total' }
          end
        end

        describe 'the next page' do
          before do
            @addresses = User::Address.page(2).per(25)
          end

          subject { helper.page_entries_info @addresses, :params => {:controller => 'addresses', :action => 'index'} }
          it      { should == 'Displaying addresses <b>26&nbsp;-&nbsp;50</b> of <b>50</b> in total' }

          context 'setting the entry name option to "place"' do
            subject { helper.page_entries_info @addresses, :entry_name => 'place', :params => {:controller => 'addresses', :action => 'index'} }
            it      { should == 'Displaying places <b>26&nbsp;-&nbsp;50</b> of <b>50</b> in total' }
          end
        end
      end
    end

    context 'on a PaginatableArray' do
      before do
        @numbers = Kaminari.paginate_array(%w{one two three}).page(1)
      end

      subject { helper.page_entries_info @numbers }
      it      { should == 'Displaying <b>all 3</b> entries' }
    end
  end

  describe '#rel_next_prev_link_tags' do
    before do
      31.times {|i| User.create! :name => "user#{i}"}
    end

    subject { helper.rel_next_prev_link_tags users, :params => {:controller => 'users', :action => 'index'} }

    context 'the first page' do
      let(:users) { User.page(1).per(10) }

      it { should_not match(/rel="prev"/) }
      it { should match(/rel="next"/) }
      it { should match(/\?page=2/) }
    end

    context 'the second page' do
      let(:users) { User.page(2).per(10) }

      it { should match(/rel="prev"/) }
      it { should_not match(/\?page=1/) }
      it { should match(/rel="next"/) }
      it { should match(/\?page=3/) }
    end

    context 'the last page' do
      let(:users) { User.page(4).per(10) }

      it { should match(/rel="prev"/) }
      it { should match(/\?page=3"/) }
      it { should_not match(/rel="next"/) }
    end
  end

  describe '#path_to_next_page' do
    before do
      2.times {|i| User.create! :name => "user#{i}"}
    end

    subject { helper.path_to_next_page users, :params => {:controller => 'users', :action => 'index'} }

    context 'the first page' do
      let(:users) { User.page(1).per(1) }
      it { should eql '/users?page=2' }
    end

    context 'the last page' do
      let(:users) { User.page(2).per(1) }
      it { should be nil }
    end
  end

  describe '#path_to_prev_page' do
    before do
      3.times {|i| User.create! :name => "user#{i}"}
    end

    subject { helper.path_to_prev_page users, :params => {:controller => 'users', :action => 'index'} }

    context 'the first page' do
      let(:users) { User.page(1).per(1) }
      it { should be nil }
    end

    context 'the second page' do
      let(:users) { User.page(2).per(1) }
      it { should eql '/users' }
    end

    context 'the last page' do
      let(:users) { User.page(3).per(1) }
      it { should eql '/users?page=2' }
    end
  end
end
