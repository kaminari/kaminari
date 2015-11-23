module Kaminari
  module EntryMethods
    def entry_name( options = {} )
      count = options.fetch(:count, 1) # back compatibility where default was singular humanized model name
      downcase = options.fetch(:downcase, true) # back compatibility where default was to downcase entry_name
      if model_name.respond_to?(:lookup_ancestors) || model_name.respond_to?(:i18n_scope)
        entry_name = model_name.human(count: count)
      else
        entry_name = model_name.human
        entry_name = entry_name.pluralize if count != 1
      end
      downcase ? entry_name.downcase : entry_name
    end
  end
end