require 'spec_helper'
include Kaminari::Helpers

describe 'Kaminari::Helpers' do
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
          subject { Paginator::PageProxy.new({:total_pages => 39}, 39, nil) }
          its(:last?) { should be_true }
        end
        context 'current_page != page' do
          subject { Paginator::PageProxy.new({:total_pages => 39}, 38, nil) }
          its(:last?) { should_not be_true }
        end
      end

      describe '#next?' do
        context 'page == current_page + 1' do
          subject { Paginator::PageProxy.new({:current_page => 52}, 53, nil) }
          its(:next?) { should be_true }
        end
        context 'page != current_page + 1' do
          subject { Paginator::PageProxy.new({:current_page => 52}, 77, nil) }
          its(:next?) { should_not be_true }
        end
      end

      describe '#prev?' do
        context 'page == current_page - 1' do
          subject { Paginator::PageProxy.new({:current_page => 77}, 76, nil) }
          its(:prev?) { should be_true }
        end
        context 'page != current_page + 1' do
          subject { Paginator::PageProxy.new({:current_page => 77}, 80, nil) }
          its(:prev?) { should_not be_true }
        end
      end

      describe '#left_outer?' do
        context 'current_page == left' do
          subject { Paginator::PageProxy.new({:left => 3}, 3, nil) }
          its(:left_outer?) { should be_true }
        end
        context 'current_page == left + 1' do
          subject { Paginator::PageProxy.new({:left => 3}, 4, nil) }
          its(:left_outer?) { should_not be_true }
        end
        context 'current_page == left + 2' do
          subject { Paginator::PageProxy.new({:left => 3}, 5, nil) }
          its(:left_outer?) { should_not be_true }
        end
      end

      describe '#right_outer?' do
        context 'total_pages - page > right' do
          subject { Paginator::PageProxy.new({:total_pages => 10, :right => 3}, 6, nil) }
          its(:right_outer?) { should_not be_true }
        end
        context 'total_pages - page == right' do
          subject { Paginator::PageProxy.new({:total_pages => 10, :right => 3}, 7, nil) }
          its(:right_outer?) { should_not be_true }
        end
        context 'total_pages - page < right' do
          subject { Paginator::PageProxy.new({:total_pages => 10, :right => 3}, 8, nil) }
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
          stub(@template = Object.new) do
            options { {} }
            params { {} }
          end
        end
        context 'last.is_a? Gap' do
          subject { Paginator::PageProxy.new({}, 10, Gap.new(@template)) }
          its(:was_truncated?) { should be_true }
        end
        context 'last.is not a Gap' do
          subject { Paginator::PageProxy.new({}, 10, Page.new(@template)) }
          its(:was_truncated?) { should_not be_true }
        end
      end
      describe '#first_page_outside_inner_and_left?' do
        context 'page == (left + 1) && page == (current_page - window - 1)' do
          subject { Paginator::PageProxy.new({:current_page => 9, :window => 3, left: 4}, 5, nil) }
          its(:first_page_outside_inner_and_left?) { should be_true }
        end
        context 'page == (left) && page == (current_page - window - 2)' do
          subject { Paginator::PageProxy.new({:current_page => 9, :window => 3, left: 4}, 4, nil) }
          its(:first_page_outside_inner_and_left?) { should_not be_true }
        end
        context 'page == (left + 2) && page == (current_page - window)' do
          subject { Paginator::PageProxy.new({:current_page => 9, :window => 3, left: 4}, 6, nil) }
          its(:first_page_outside_inner_and_left?) { should_not be_true }
        end
      end
      describe '#first_page_outside_inner_and_right?' do
        context 'page == (total_pages - right) && page == (current_page + window + 1)' do
          subject { Paginator::PageProxy.new({:total_pages => 17, :current_page => 9, :window => 3, right: 4}, 13, nil) }
          its(:first_page_outside_inner_and_right?) { should be_true }
        end
        context 'page == (total_pages - right + 1) && page == (current_page + window + 2)' do
          subject { Paginator::PageProxy.new({:total_pages => 17, :current_page => 9, :window => 3, right: 4}, 14, nil) }
          its(:first_page_outside_inner_and_right?) { should_not be_true }
        end
        context 'page == (total_pages - right - 1) && page == (current_page + window)' do
          subject { Paginator::PageProxy.new({:total_pages => 17, :current_page => 9, :window => 3, right: 4}, 12, nil) }
          its(:first_page_outside_inner_and_right?) { should_not be_true }
        end
      end
      describe '#avoids_single_truncation?' do
        context '#first_page_outside_inner_and_left? == true' do
          subject { Paginator::PageProxy.new({:current_page => 9, :window => 3, left: 4}, 5, nil) }
          its(:avoids_single_truncation?) { should be_true }
        end
        context '#first_page_outside_inner_and_right? == true' do
          subject { Paginator::PageProxy.new({:total_pages => 17, :current_page => 9, :window => 3, right: 4}, 13, nil) }
          its(:avoids_single_truncation?) { should be_true }
        end
        context '#first_page_outside_inner_and_left? == #first_page_outside_inner_and_right? == false' do
          subject { Paginator::PageProxy.new({:current_page => 9, :window => 2, left: 4}, 5, nil) }
          its(:avoids_single_truncation?) { should_not be_true }
        end
      end
      describe '#display_tag?' do
        context '#left_outer? == true' do
          subject { Paginator::PageProxy.new({:total_pages => 15, :current_page => 8, :left => 3, :right => 3, :window => 3}, 1, nil) }
          its(:display_tag?) {should be_true}
        end
        context '#right_outer? == true' do
          subject { Paginator::PageProxy.new({:total_pages => 15, :current_page => 8, :left => 3, :right => 3, :window => 3 }, 15, nil) }
          its(:display_tag?) { should be_true }
        end
        context '#inside_window? == true' do
          subject { Paginator::PageProxy.new({:total_pages => 15, :current_page => 8, :left => 3, :right => 3, :window => 3 }, 9, nil) }
          its(:display_tag?) { should be_true }
        end
        context '#avoids_single_truncation? == true' do
          subject { Paginator::PageProxy.new({:total_pages => 15, :current_page => 8, :left => 3, :right => 3, :window => 3 }, 12, nil) }
          its(:display_tag?) { should be_true }
        end
        context 'All of the above is false' do
          subject { Paginator::PageProxy.new({:total_pages => 15, :current_page => 9, :left => 3, :right => 3, :window => 3 }, 4, nil) }
          its(:display_tag?) { should_not be_true }
        end
      end
    end
  end
end
