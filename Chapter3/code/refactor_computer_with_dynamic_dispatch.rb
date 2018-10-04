require 'test/unit'
require_relative 'ds'

class Computer
  def initialize(computer_id, data_source)
    @id = computer_id
    @data_source = data_source
  end

  def mouse
    component :mouse
  end

  def cpu
    component :cpu
  end

  def keyboard
    component :keyboard
  end

  def component(name)
    info = @data_source.send("get_#{name}_info", @id)
    price = @data_source.send("get_#{name}_price", @id)
    result = "#{name.capitalize}: #{info} ($#{price})"
    return "* #{result}" if price >= 100
    result
  end
end

class RefactorComputerWithDynamicDispatchTest < Test::Unit::TestCase
  test :mouse do
    id = 4
    data = DS.new
    computer = Computer.new(id, data)
    assert_equal computer.mouse, '* Mouse: Magic Mouse ($720)'
  end
end
