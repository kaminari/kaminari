module Kaminari
  module TestHelpers

    def stub_pagination(resource, options={})
      return nil unless resource
      mock_framework = options[:mock] || :rr
      values = calculate_values(resource, options)
      case mock_framework
        when :rspec then stub_pagination_with_rspec(resource, values)
        when :rr then stub_pagination_with_rr(resource, values)
        when :mocha then stub_pagination_with_mocha(resource, values)
        when :flexmock then stub_pagination_with_flexmock(resource, values)
        when :nothing then resource
        else
          raise ArgumentError, "Invalid mock argument #{options[:mock]} / framework not supported"
      end
    end

    def discover_mock_framework

      mock_framework = RSpec.configuration.mock_framework
      return mock_framework.framework_name if mock_framework.respond_to? :framework_name
      puts("WARNING: Could not detect mocking framework, defaulting to :nothing, use :mock option to override")
      return :nothing

    end


    def calculate_values(resource, options={})

      values = {}
      values[:total_count] = options[:total_count] || (resource.respond_to?(:length) ? resource.length : 1)
      values[:per_page] = options[:per_page] || 25
      values[:num_pages] = (values[:total_count] / values[:per_page]) + ((values[:total_count] % values[:per_page]) == 0 ? 0 : 1)
      values[:current_page] = options[:current_page] || 1
      return values
    end

    def stub_pagination_with_rspec(resource, values)

      values.each do |key, value |
        resource.stub(key).and_return(value)
      end

      return resource

    end

    def stub_pagination_with_rr(resource, values)

      values.each do |key, value|
        eval "stub(resource).#{key} { #{value} }"
      end

      return resource

    end

    def stub_pagination_with_mocha(resource, values)

      values.each do |key, value|
        resource.stubs(key).returns(value)
      end

      return resource

    end

    def stub_pagination_with_flexmock(resource, values)

      mock = flexmock(resource)

      values.each do |key, value|
        mock.should_receive(key).zero_or_more_times.and_return(value)
      end

      return mock

    end

  end
end