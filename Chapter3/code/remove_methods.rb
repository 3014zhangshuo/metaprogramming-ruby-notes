class ElectronicEquipment
  def display
    "Liquid crystal"
  end
end

class Computer < ElectronicEquipment
  def display
    "Dell"
  end
end

Computer.class_eval do
  undef_method :display
end

Computer.new.display # => NoMethodError

Computer.class_eval do
  remove_method :display
end

Computer.new.display # => Liquid crystal
