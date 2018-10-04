require 'test/unit'
require_relative 'with'

class TestWith < Test::Unit::TestCase
  class Resource
    def dispose
      @dispose = true
    end

    def dispose?
      @dispose
    end
  end

  test 'dispose of resource' do
    r = Resource.new
    with(r) {  }
    assert r.dispose?
  end

  test 'dispose of resource in case of exception' do
    r = Resource.new
    assert_raises(Exception) do
      with(r) { raise Exception }
    end

    assert r.dispose?
  end
end
