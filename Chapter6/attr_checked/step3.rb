require 'test/unit'

class Person; end

def add_checked_attributes(klass, attribute, &validation)
  klass.class_eval do
    define_method "#{attribute}=" do |value|
      raise 'Invalid attribute' unless validation.call(value)
      instance_variable_set("@#{attribute}", value)
    end

    define_method "#{attribute}" do
      instance_variable_get("@#{attribute}")
    end
  end
end

class TestCheckedAttribute < Test::Unit::TestCase
  setup do
    add_checked_attributes(Person, :age) { |age| age >= 18 }
    @bob = Person.new
  end

  test 'accepts valid values' do
    @bob.age = 20
    assert_equal 20, @bob.age
  end

  test 'refuses invalid values' do
    assert_raises RuntimeError, 'Invalid attribute' do
      @bob.age = 17
    end
  end
end
