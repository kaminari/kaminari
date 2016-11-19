# frozen_string_literal: true
#
# kaminari repo's tests successfully runs without DatabaseCleaner now.
# DatabaseCleaner[:active_record].strategy = :transaction if defined? ActiveRecord

# class ActiveSupport::TestCase
#   class << self
#     def startup
#       DatabaseCleaner.clean_with :truncation if defined? ActiveRecord
#       super
#     end
#   end

#   setup do
#     DatabaseCleaner.start
#   end

#   teardown do
#     DatabaseCleaner.clean
#   end
# end
