require 'spec_helper'
include Kaminari::Helpers

describe 'Kaminari::Helpers', :type => :helper do
  describe 'Tag' do
    describe '#page_url_for', :if => defined?(Rails) do
      context "with a friendly route setting" do
        before do
          helper.request.assign_parameters(_routes, "addresses", "index", :page => 3)
        end

        context "for first page" do
          subject { Tag.new(helper).page_url_for(1) }
          it { is_expected.to eq("/addresses") }
        end

        context "for other page" do
          subject { Tag.new(helper).page_url_for(5) }
          it { is_expected.to eq("/addresses/page/5") }
        end
      end

      context "with param_name = 'user[page]' option" do
        before do
          helper.request.assign_parameters(_routes, "users", "index")
          helper.params.merge!(:user => {:page => "3", :scope => "active"})
        end

        context "for first page" do
          subject { Tag.new(helper, :param_name => "user[page]").page_url_for(1) }
          if ActiveSupport::VERSION::STRING < "3.1.0"
            it { is_expected.not_to match(/user\[page\]=\d+/) }
            it { is_expected.to match(/user\[scope\]=active/) }
          else
            it { is_expected.not_to match(/user%5Bpage%5D=\d+/) } # not match user[page]=\d+
            it { is_expected.to match(/user%5Bscope%5D=active/) } #     match user[scope]=active
          end
        end

        context "for other page" do
          subject { Tag.new(helper, :param_name => "user[page]").page_url_for(2) }
          if ActiveSupport::VERSION::STRING < "3.1.0"
            it { is_expected.to match(/user\[page\]=2/) }
            it { is_expected.to match(/user\[scope\]=active/) }
          else
            it { is_expected.to match(/user%5Bpage%5D=2/) }       # match user[page]=2
            it { is_expected.to match(/user%5Bscope%5D=active/) } # match user[scope]=active
          end
        end
      end
    end
  end

  describe 'Paginator' do
    describe 'Paginator::PageProxy' do
      describe '#current?' do
        context 'current_page == page' do
          subject { Paginator::PageProxy.new({:current_page => 26}, 26, nil) }

          describe '#current?' do
            subject { super().current? }
            it { is_expected.to be_truthy }
          end
        end
        context 'current_page != page' do
          subject { Paginator::PageProxy.new({:current_page => 13}, 26, nil) }

          describe '#current?' do
            subject { super().current? }
            it { is_expected.not_to be_truthy }
          end
        end
      end

      describe '#first?' do
        context 'page == 1' do
          subject { Paginator::PageProxy.new({:current_page => 26}, 1, nil) }

          describe '#first?' do
            subject { super().first? }
            it { is_expected.to be_truthy }
          end
        end
        context 'page != 1' do
          subject { Paginator::PageProxy.new({:current_page => 13}, 2, nil) }

          describe '#first?' do
            subject { super().first? }
            it { is_expected.not_to be_truthy }
          end
        end
      end

      describe '#last?' do
        context 'current_page == page' do
          subject { Paginator::PageProxy.new({:total_pages => 39}, 39, nil) }

          describe '#last?' do
            subject { super().last? }
            it { is_expected.to be_truthy }
          end
        end
        context 'current_page != page' do
          subject { Paginator::PageProxy.new({:total_pages => 39}, 38, nil) }

          describe '#last?' do
            subject { super().last? }
            it { is_expected.not_to be_truthy }
          end
        end
      end

      describe '#next?' do
        context 'page == current_page + 1' do
          subject { Paginator::PageProxy.new({:current_page => 52}, 53, nil) }

          describe '#next?' do
            subject { super().next? }
            it { is_expected.to be_truthy }
          end
        end
        context 'page != current_page + 1' do
          subject { Paginator::PageProxy.new({:current_page => 52}, 77, nil) }

          describe '#next?' do
            subject { super().next? }
            it { is_expected.not_to be_truthy }
          end
        end
      end

      describe '#prev?' do
        context 'page == current_page - 1' do
          subject { Paginator::PageProxy.new({:current_page => 77}, 76, nil) }

          describe '#prev?' do
            subject { super().prev? }
            it { is_expected.to be_truthy }
          end
        end
        context 'page != current_page + 1' do
          subject { Paginator::PageProxy.new({:current_page => 77}, 80, nil) }

          describe '#prev?' do
            subject { super().prev? }
            it { is_expected.not_to be_truthy }
          end
        end
      end

      describe '#left_outer?' do
        context 'current_page == left' do
          subject { Paginator::PageProxy.new({:left => 3}, 3, nil) }

          describe '#left_outer?' do
            subject { super().left_outer? }
            it { is_expected.to be_truthy }
          end
        end
        context 'current_page == left + 1' do
          subject { Paginator::PageProxy.new({:left => 3}, 4, nil) }

          describe '#left_outer?' do
            subject { super().left_outer? }
            it { is_expected.not_to be_truthy }
          end
        end
        context 'current_page == left + 2' do
          subject { Paginator::PageProxy.new({:left => 3}, 5, nil) }

          describe '#left_outer?' do
            subject { super().left_outer? }
            it { is_expected.not_to be_truthy }
          end
        end
      end

      describe '#right_outer?' do
        context 'total_pages - page > right' do
          subject { Paginator::PageProxy.new({:total_pages => 10, :right => 3}, 6, nil) }

          describe '#right_outer?' do
            subject { super().right_outer? }
            it { is_expected.not_to be_truthy }
          end
        end
        context 'total_pages - page == right' do
          subject { Paginator::PageProxy.new({:total_pages => 10, :right => 3}, 7, nil) }

          describe '#right_outer?' do
            subject { super().right_outer? }
            it { is_expected.not_to be_truthy }
          end
        end
        context 'total_pages - page < right' do
          subject { Paginator::PageProxy.new({:total_pages => 10, :right => 3}, 8, nil) }

          describe '#right_outer?' do
            subject { super().right_outer? }
            it { is_expected.to be_truthy }
          end
        end
      end

      describe '#inside_window?' do
        context 'page > current_page' do
          context 'page - current_page > window' do
            subject { Paginator::PageProxy.new({:current_page => 4, :window => 5}, 10, nil) }

            describe '#inside_window?' do
              subject { super().inside_window? }
              it { is_expected.not_to be_truthy }
            end
          end
          context 'page - current_page == window' do
            subject { Paginator::PageProxy.new({:current_page => 4, :window => 6}, 10, nil) }

            describe '#inside_window?' do
              subject { super().inside_window? }
              it { is_expected.to be_truthy }
            end
          end
          context 'page - current_page < window' do
            subject { Paginator::PageProxy.new({:current_page => 4, :window => 7}, 10, nil) }

            describe '#inside_window?' do
              subject { super().inside_window? }
              it { is_expected.to be_truthy }
            end
          end
        end
        context 'current_page > page' do
          context 'current_page - page > window' do
            subject { Paginator::PageProxy.new({:current_page => 15, :window => 4}, 10, nil) }

            describe '#inside_window?' do
              subject { super().inside_window? }
              it { is_expected.not_to be_truthy }
            end
          end
          context 'current_page - page == window' do
            subject { Paginator::PageProxy.new({:current_page => 15, :window => 5}, 10, nil) }

            describe '#inside_window?' do
              subject { super().inside_window? }
              it { is_expected.to be_truthy }
            end
          end
          context 'current_page - page < window' do
            subject { Paginator::PageProxy.new({:current_page => 15, :window => 6}, 10, nil) }

            describe '#inside_window?' do
              subject { super().inside_window? }
              it { is_expected.to be_truthy }
            end
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

          describe '#was_truncated?' do
            subject { super().was_truncated? }
            it { is_expected.to be_truthy }
          end
        end
        context 'last.is not a Gap' do
          subject { Paginator::PageProxy.new({}, 10, Page.new(@template)) }

          describe '#was_truncated?' do
            subject { super().was_truncated? }
            it { is_expected.not_to be_truthy }
          end
        end
      end
      describe "#single_gap?" do
        let(:window_options) do
          {
            :left => 1,
            :window => 1,
            :right => 1,
            :total_pages => 9
          }
        end

        def gap_for(page)
          Paginator::PageProxy.new(window_options, page, nil)
        end

        context "in case of '1 ... 4 5 6 ... 9'" do
          before { window_options[:current_page] = 5 }

          describe '#gap for 2' do
            subject { super().gap_for 2 }
            it { gap_for(2).should_not be_a_single_gap }
          end

          describe '#gap for 3' do
            subject { super().gap_for 3 }
            it { gap_for(3).should_not be_a_single_gap }
          end

          describe '#gap for 7' do
            subject { super().gap_for 7 }
            it { gap_for(7).should_not be_a_single_gap }
          end

          describe '#gap for 8' do
            subject { super().gap_for 8 }
            it { gap_for(8).should_not be_a_single_gap }
          end
        end

        context "in case of '1 ... 3 4 5 ... 9'" do
          before { window_options[:current_page] = 4 }

          describe '#gap for 2' do
            subject { super().gap_for 2 }
            it { gap_for(2).should be_a_single_gap }
          end

          describe '#gap for 6' do
            subject { super().gap_for 6 }
            it { gap_for(6).should_not be_a_single_gap }
          end

          describe '#gap for 8' do
            subject { super().gap_for 8 }
            it { gap_for(8).should_not be_a_single_gap }
          end
        end

        context "in case of '1 ... 3 4 5 ... 7'" do
          before do
            window_options[:current_page] = 4
            window_options[:total_pages] = 7
          end

          describe '#gap for 2' do
            subject { super().gap_for 2 }
            it { gap_for(2).should be_a_single_gap }
          end

          describe '#gap for 6' do
            subject { super().gap_for 6 }
            it { gap_for(6).should be_a_single_gap }
          end
        end

        context "in case of '1 ... 5 6 7 ... 9'" do
          before { window_options[:current_page] = 6 }

          describe '#gap for 2' do
            subject { super().gap_for 2 }
            it { gap_for(2).should_not be_a_single_gap }
          end

          describe '#gap for 4' do
            subject { super().gap_for 4 }
            it { gap_for(4).should_not be_a_single_gap }
          end

          describe '#gap for 8' do
            subject { super().gap_for 8 }
            it { gap_for(8).should be_a_single_gap }
          end
        end
      end

      describe "#out_of_range?" do
        context 'within range' do
          subject { Paginator::PageProxy.new({:total_pages => 5}, 4, nil).out_of_range? }
          it { is_expected.to eq(false) }
        end

        context 'on last page' do
          subject { Paginator::PageProxy.new({:total_pages => 5}, 5, nil).out_of_range? }
          it { is_expected.to eq(false) }
        end

        context 'out of range' do
          subject { Paginator::PageProxy.new({:total_pages => 5}, 6, nil).out_of_range? }
          it { is_expected.to eq(true) }
        end
      end
    end
  end
end
