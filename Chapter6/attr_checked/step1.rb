require 'test/unit'

class Person; end

def add_checked_attributes(klass, attribute)
  eval <<-end_eval
    class #{klass}
      def #{attribute}=(value)
        raise 'Invalid attribute' unless value
        @#{attribute} = value
      end

      def #{attribute}
        @#{attribute}
      end
    end
  end_eval
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
