module Kaminari
  module Helpers
    def paginate(scope, options = {}, &block)
      prev_label, next_label, left, window, right, truncate, style = (options[:prev] || '&laquo; Prev'.html_safe), (options[:next] || 'Next &raquo;'.html_safe), (options[:left] || 2), (options[:window] || 5), (options[:right] || 2), (options[:truncate] || '...'), (options[:style] || 'page')
      current_page, num_pages = scope.current_page, scope.num_pages

      content_tag :div, :class => 'pagination' do
        ''.html_safe.tap do |html|
          # prev_link
          html << link_to_if((current_page > 1), prev_label, url_for(:page => current_page - 1), :class => 'prev', :rel => 'prev') do
            content_tag :span, prev_label, :class => 'prev'
          end << "\n"

          # page links
          truncated = false
          (1..num_pages).each do |i|
            html << if (i <= left) || ((num_pages - i) < right) || ((i - current_page).abs < window)
              truncated = false
              content_tag :span, :class => "#{style}#{i == current_page ? ' current' : ''}" do
                if i == 1
                  #TODO pageが1だったらパラメーターからpageを取り除く
                  link_to_unless_current i.to_s, :page => i
                else
                  link_to_unless_current i.to_s, :page => i
                end
              end
            else
              content_tag(:span, truncate, :class => style).tap { truncated = true } unless truncated
            end << "\n"
          end

          # next_link
          html << link_to_if((current_page < num_pages), next_label, url_for(:page => current_page + 1), :class => 'next', :rel => 'next') do
            content_tag :span, next_label, :class => 'next'
          end
        end
      end
    end
  end
end
