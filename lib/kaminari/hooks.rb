module Kaminari
  class Hooks
    def self.init
      ActiveSupport.on_load(:active_record) do
        require 'kaminari/models/active_record_extension'
        ::ActiveRecord::Base.send :include, Kaminari::ActiveRecordExtension
      end

      require 'kaminari/models/array_extension'

      ActiveSupport.on_load(:action_view) do
        require 'kaminari/helpers/action_view_extension'
        ::ActionView::Base.send :include, Kaminari::ActionViewExtension
      end
    end
  end
end
