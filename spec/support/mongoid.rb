RSpec.configure do |config|
  config.before :suite do
    # Mongoid 5 is very noisy at DEBUG level by default
    Mongoid.logger.level = Logger::INFO
    Mongo::Logger.logger.level = Logger::INFO if defined?(Mongo)
  end
end if defined? Mongoid
