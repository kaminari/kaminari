require File.expand_path('../spec_helper', File.dirname(__FILE__))
include Kaminari::Helpers

describe 'Kaminari::Helpers' do
  describe 'template lookup rule' do
    describe 'Paginator' do
      subject { Paginator }
      its(:ancestor_renderables) { should == [Paginator] }
    end
    describe 'PrevLink' do
      subject { PrevLink }
      its(:ancestor_renderables) { should == [PrevLink, Prev, Link, Page] }
    end
    describe 'PrevSpan' do
      subject { PrevSpan }
      its(:ancestor_renderables) { should == [PrevSpan, Prev, NonLink] }
    end
    describe 'FirstPageLink' do
      subject { FirstPageLink }
      its(:ancestor_renderables) { should == [FirstPageLink, PageLink, Link, Page] }
    end
    describe 'PageLink' do
      subject { PageLink }
      its(:ancestor_renderables) { should == [PageLink, Link, Page] }
    end
    describe 'CurrentPage' do
      subject { CurrentPage }
      its(:ancestor_renderables) { should == [CurrentPage, NonLink, Page] }
    end
    describe 'TruncatedSpan' do
      subject { TruncatedSpan }
      its(:ancestor_renderables) { should == [TruncatedSpan, NonLink] }
    end
    describe 'LastPageLink' do
      subject { LastPageLink }
      its(:ancestor_renderables) { should == [LastPageLink, PageLink, Link, Page] }
    end
    describe 'NextLink' do
      subject { NextLink }
      its(:ancestor_renderables) { should == [NextLink, Next, Link, Page] }
    end
    describe 'NextSpan' do
      subject { NextSpan }
      its(:ancestor_renderables) { should == [NextSpan, Next, NonLink] }
    end
  end

  describe 'Paginator' do
    describe 'Paginator::PageProxy' do
      describe '#current?' do
        context 'current_page == page' do
          subject { Paginator::PageProxy.new({:current_page => 26}, 26, nil) }
          its(:current?) { should be_true }
        end
        context 'current_page != page' do
          subject { Paginator::PageProxy.new({:current_page => 13}, 26, nil) }
          its(:current?) { should_not be_true }
        end
      end

      describe '#first?' do
        context 'page == 1' do
          subject { Paginator::PageProxy.new({:current_page => 26}, 1, nil) }
          its(:first?) { should be_true }
        end
        context 'page != 1' do
          subject { Paginator::PageProxy.new({:current_page => 13}, 2, nil) }
          its(:first?) { should_not be_true }
        end
      end

      describe '#last?' do
        context 'current_page == page' do
          subject { Paginator::PageProxy.new({:num_pages => 39}, 39, nil) }
          its(:last?) { should be_true }
        end
        context 'current_page != page' do
          subject { Paginator::PageProxy.new({:num_pages => 39}, 38, nil) }
          its(:last?) { should_not be_true }
        end
      end

      describe '#left_outer?' do
        context 'current_page == left' do
          subject { Paginator::PageProxy.new({:left => 3}, 3, nil) }
          its(:left_outer?) { should be_true }
        end
        context 'current_page == left + 1' do
          subject { Paginator::PageProxy.new({:left => 3}, 4, nil) }
          its(:left_outer?) { should be_true }
        end
        context 'current_page == left + 2' do
          subject { Paginator::PageProxy.new({:left => 3}, 5, nil) }
          its(:left_outer?) { should_not be_true }
        end
      end

      describe '#right_outer?' do
        context 'num_pages - page > right' do
          subject { Paginator::PageProxy.new({:num_pages => 10, :right => 3}, 6, nil) }
          its(:right_outer?) { should_not be_true }
        end
        context 'num_pages - page == right' do
          subject { Paginator::PageProxy.new({:num_pages => 10, :right => 3}, 7, nil) }
          its(:right_outer?) { should be_true }
        end
        context 'num_pages - page < right' do
          subject { Paginator::PageProxy.new({:num_pages => 10, :right => 3}, 8, nil) }
          its(:right_outer?) { should be_true }
        end
      end

      describe '#inside_window?' do
        context 'page > current_page' do
          context 'page - current_page > window' do
            subject { Paginator::PageProxy.new({:current_page => 4, :window => 5}, 10, nil) }
            its(:inside_window?) { should_not be_true }
          end
          context 'page - current_page == window' do
            subject { Paginator::PageProxy.new({:current_page => 4, :window => 6}, 10, nil) }
            its(:inside_window?) { should be_true }
          end
          context 'page - current_page < window' do
            subject { Paginator::PageProxy.new({:current_page => 4, :window => 7}, 10, nil) }
            its(:inside_window?) { should be_true }
          end
        end
        context 'current_page > page' do
          context 'current_page - page > window' do
            subject { Paginator::PageProxy.new({:current_page => 15, :window => 4}, 10, nil) }
            its(:inside_window?) { should_not be_true }
          end
          context 'current_page - page == window' do
            subject { Paginator::PageProxy.new({:current_page => 15, :window => 5}, 10, nil) }
            its(:inside_window?) { should be_true }
          end
          context 'current_page - page < window' do
            subject { Paginator::PageProxy.new({:current_page => 15, :window => 6}, 10, nil) }
            its(:inside_window?) { should be_true }
          end
        end
      end
      describe '#was_truncated?' do
        before do
          stub(@template = Object.new).options { {} }
        end
        context 'last.is_a? TruncatedSpan' do
          subject { Paginator::PageProxy.new({}, 10, TruncatedSpan.new(@template)) }
          its(:was_truncated?) { should be_true }
        end
        context 'last.is not a TruncatedSpan' do
          subject { Paginator::PageProxy.new({}, 10, PageLink.new(@template)) }
          its(:was_truncated?) { should_not be_true }
        end
      end
    end
  end
end
