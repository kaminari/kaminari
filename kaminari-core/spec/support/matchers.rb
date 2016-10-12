# frozen_string_literal: true
RSpec::Matchers.define :contain_tag do |klass|
  match do |collection|
    if @num.blank?
      collection.any? {|tag| tag.is_a? klass}
    else
      (@count = collection.count {|tag| tag.is_a? klass}) == @num
    end
  end

  def count(num)
    @num = num
    self
  end

  description do
    "contain #{@num || 'any'} instance(s) of #{klass.name}"
  end
  failure_message_for_should do |_collection|
    "expected #{@num || 'any'} instance(s) of #{klass.name} but was #{@count}"
  end
end

RSpec::Matchers.define :skip do |num|
  match do |criteria|
    criteria.instance_variable_get('@options')[:skip] == num
  end
end

RSpec::Matchers.define :offset do |num|
  match do |collection|
    collection.offset_value == num
  end
end
