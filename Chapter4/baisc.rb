def a_method(a, b)
  a + yield(a, b)
end

a_method(1, 2) { |x, y| x + y } # => 4

def a_method
  return yield if block_given?
  'no block'
end

a_method { 'is a block' }
a_method
