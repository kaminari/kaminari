module Kaminari
  module TestHelpers

    def stub_pagination_methods(resource, options={})
      return nil unless resource
      total_count = options[:total_count] || (resource.respond_to?(:length) ? resource.length : 1)
      per_page = options[:per_page] || 25
      num_pages = (total_count / per_page) + 1
      current_page = options[:current_page] || 1
      resource.stub(:current_page).and_return(current_page)
      resource.stub(:num_pages).and_return(num_pages)
      resource.stub(:limit_value).and_return(per_page)
      # redundant return, but makes it clearer
      return resource
    end

  end
end