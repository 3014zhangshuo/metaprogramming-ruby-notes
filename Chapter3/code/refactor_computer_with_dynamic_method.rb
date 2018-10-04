require 'test/unit'
require_relative 'ds'

class Computer
  def initialize(computer_id, data_source)
    @id = computer_id
    @data_source = data_source
  end

  def self.define_component(name)
    define_method name do
      info = @data_source.send("get_#{name}_info", @id)
      price = @data_source.send("get_#{name}_price", @id)
      result = "#{name.capitalize}: #{info} ($#{price})"
      return "* #{result}" if price >= 100
      result
    end
  end

  define_component :mouse
  define_component :cpu
  define_component :keyboard
end

class RefactorComputerWithDynamicMethodTest < Test::Unit::TestCase
  test :mouse do
    id = 4
    data = DS.new
    computer = Computer.new(id, data)
    assert_equal computer.mouse, '* Mouse: Magic Mouse ($720)'
  end
end
