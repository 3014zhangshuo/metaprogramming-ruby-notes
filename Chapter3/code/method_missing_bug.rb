begin
  class Roulette
    def method_missing(name, *args)
      person = name.to_s.capitalize
      3.times do
        number = rand(10) + 1
        puts "#{number}..."
      end
      "#{person} got a #{number}"
    end
  end

  # triger stack level too deep (SystemStackError) becasuse number recognized as
  # the method with invisible self，it's will be arrived method_missing forever.
  number_of = Roulette.new
  puts number_of.bob
  puts number_of.frank
rescue SystemStackError
  class FixedRoulette
    def method_missing(name, *args)
      person = name.to_s.capitalize
      super unless %w[Bob Frank Bill].include? person
      number = 0
      3.times do
        number = rand(10) + 1
        puts "#{number}..."
      end
      "#{person} got a #{number}"
    end
  end

  number_of = FixedRoulette.new
  puts number_of.bob
  puts number_of.frank
end
