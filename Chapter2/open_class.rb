class String
  def to_alphanumeric
    gsub(/[^\w\s]/, '')
  end
end

require 'test/unit'

class StringExtensionsText < Test::Unit::TestCase
  test 'string non alphanumeric characters' do
    assert_equal '3 the Magic Number', '#3, the *Magic Number*?'.to_alphanumeric
  end
end
