# Monkey-patching test-unit-rails not to raise NameError from triple-nested sub_test_case
ActionView::TestCase.class_eval do
  class << self
    def sub_test_case(name, &block)
      parent_test_case = self
      sub_test_case = Class.new(self) do
        singleton_class = class << self; self; end
        singleton_class.__send__(:define_method, :name) do
          [parent_test_case.name, name].compact.join("::")
        end
        singleton_class.__send__(:define_method, :anonymous?) do
          true
        end
      end
      sub_test_case.class_eval(&block)
      sub_test_case
    end
  end
end
