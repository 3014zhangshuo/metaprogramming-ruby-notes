require 'test/unit'
require_relative 'ds'

class Computer
  def initialize(computer_id, data_source)
    @id = computer_id
    @data_source = data_source
  end

  def method_missing(name)
    super unless @data_source.respond_to?("get_#{name}_info")
    info = @data_source.send("get_#{name}_info", @id)
    price = @data_source.send("get_#{name}_price", @id)
    result = "#{name.capitalize}: #{info} ($#{price})"
    return "* #{result}" if price >= 100
    result
  end

  def respond_to_missing(name, include_private = false)
    @data_source.respond_to?("get_#{name}_info") || super
  end
end

class RefactorComputerWithMethodMissingTest < Test::Unit::TestCase
  test :mouse do
    id = 4
    data = DS.new
    computer = Computer.new(id, data)
    assert_equal computer.mouse, '* Mouse: Magic Mouse ($720)'
  end
end
