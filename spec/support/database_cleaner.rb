DatabaseCleaner[:active_record].strategy = :transaction if defined? ActiveRecord

RSpec.configure do |config|
  config.before :suite do
    DatabaseCleaner.clean_with :truncation if defined? ActiveRecord
  end
  config.before :each do
    DatabaseCleaner.start
  end
  config.after :each do
    DatabaseCleaner.clean
  end
end
