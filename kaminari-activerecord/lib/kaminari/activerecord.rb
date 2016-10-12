# frozen_string_literal: true
require "kaminari/activerecord/version"

ActiveSupport.on_load :active_record do
  require 'kaminari/activerecord/active_record_extension'
  ::ActiveRecord::Base.send :include, Kaminari::ActiveRecordExtension
end
