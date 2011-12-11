require 'kaminari/sinatra'
require 'rack/test'
require 'sinatra/test_helpers'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Sinatra::TestHelpers
end

require 'nokogiri'
def last_document
  Nokogiri::HTML(last_response.body)
end
