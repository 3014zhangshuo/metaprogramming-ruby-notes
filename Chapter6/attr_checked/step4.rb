require 'test/unit'

class Class
  def attr_checked(attribute, &validation)
    define_method "#{attribute}=" do |value|
      raise 'Invalid attribute' unless validation.call(value)
      instance_variable_set("@#{attribute}", value)
    end

    define_method "#{attribute}" do
      instance_variable_get("@#{attribute}")
    end
  end
end

class Person
  attr_checked :age do |v|
    v >= 18
  end
end

class TestCheckedAttribute < Test::Unit::TestCase
  setup do
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
