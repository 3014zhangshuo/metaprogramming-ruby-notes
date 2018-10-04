require 'test/unit'

class Person; end

def add_checked_attributes(klass, attribute)
  klass.class_eval do
    define_method "#{attribute}=" do |value|
      raise 'Invalid attribute' unless value
      instance_variable_set("@#{attribute}", value)
    end

    define_method "#{attribute}" do
      instance_variable_get("@#{attribute}")
    end
  end
end

class TestCheckedAttribute < Test::Unit::TestCase
  setup do
    add_checked_attributes(Person, :age)
    @bob = Person.new
  end

  test 'accepts valid values' do
    @bob.age = 20
    assert_equal 20, @bob.age
  end

  test 'refuses nil values' do
    assert_raises RuntimeError, 'Invalid attribute' do
      @bob.age = nil
    end
  end

  test 'refuses false values' do
    assert_raises RuntimeError, 'Invalid attribute' do
      @bob.age = false
    end
  end
end
