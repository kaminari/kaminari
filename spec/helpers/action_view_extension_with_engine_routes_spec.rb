require 'spec_helper'

describe 'Kaminari::ActionViewExtension with engine routes', :if => defined?(Rails) do

  let(:num_users) { 50 }
  before do
    num_users.times {|i| User.create! :name => "user#{i}"}
  end

  describe '#paginate' do
    let(:users) { User.page(1) }
    subject { helper.paginate users, :params => {:controller => 'my_engine/items', :action => 'index'}, :route_set => my_engine }
    it { should match(%r(/mounted_engine/items)) }
  end

  describe '#link_to_previous_page' do
    context 'having previous pages' do
      let(:num_users) { 60 }
      let(:users) { User.page(3) }

      subject { helper.link_to_previous_page users, 'Previous', :params => {:controller => 'my_engine/items', :action => 'index'}, :route_set => my_engine }
      it { should match(%r(/mounted_engine/items)) }
    end
  end

  describe '#link_to_next_page' do
    context 'having more page' do
      let(:users) { User.page(1) }

      subject { helper.link_to_next_page users, 'More', :params => {:controller => 'my_engine/items', :action => 'index'}, :route_set => my_engine }
      it { should match(%r(/mounted_engine/items)) }
    end
  end

  describe '#rel_next_prev_link_tags' do
    let(:users) { User.page(1).per(10) }
    subject { helper.rel_next_prev_link_tags users, :params => {:controller => 'my_engine/items', :action => 'index'}, :route_set => my_engine }

    it { should match(%r(/mounted_engine/items)) }
  end
end
