class String
  def self.inherited(subclass)
    puts "#{self} was inherited by #{subclass}"
  end
end

class MyString < String; end # => String was inherited by MyString

module M1
  def self.included(othermod)
    puts "M1 was included into #{othermod}"
  end
end

module M2
  def self.prepended(othermod)
    puts "M2 was prepended into #{othermod}"
  end
end

class C
  include M1
  prepend M2
end

# => M1 was included into C
# => M2 was prepended into C
