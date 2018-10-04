class Loan
  def initialize(book)
    @book = book
    @time = Loan.time_class.now
  end

  def self.time_class
    @time_class || Time
  end

  def to_s
    "#{@book} loaned on #{@time}"
  end
end

module FakeTime
  def self.now
    'Mon Apr 18 12:15:30'
  end
end

require 'test/unit'

class TestLoan < Test::Unit::TestCase
  test 'conversation to string' do
    Loan.instance_eval { @time_class = FakeTime }
    loan = Loan.new("War And Peace")
    assert_equal "War And Peace loaned on Mon Apr 18 12:15:30", loan.to_s
  end
end
