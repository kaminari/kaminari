require File.expand_path('../spec_helper', File.dirname(__FILE__))
include Kaminari::Helpers

describe 'Kaminari::Helpers' do
  let :renderer do
    stub(r = Object.new) do
      render.with_any_args
      options { {} }
      params { {} }
      partial_exists?.with_any_args {|a| puts a; false }
      url_for {|h| "/foo?page=#{h[:page]}"}
    end
    r
  end
  describe 'PageLink' do
    subject { PageLink.new renderer, :page => 3 }
    its('class.template_filename') { should == 'page_link' }
    describe 'template lookup rule' do
      before do
        pending "spies doesn't work on RSpec 2 ATM: https://github.com/btakita/rr/issues#issue/45"
        subject.to_s
      end
      specify { renderer.should have_received.partial_exists? PageLink }
    end
  end
end
