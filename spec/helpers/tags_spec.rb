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
end
