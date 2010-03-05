require "test/unit"
require "blpwrapper"

class TestBlh < Test::Unit::TestCase
  def setup
    @conn = Blpwrapper.new
  end
  
  def test_blh
    result = @conn.blh("RYA ID Equity", "PX_LAST", "20071229", "20080102")
    assert_equal [
      [Date.civil(2007,12,31), 4.63],
      [Date.civil(2008, 1, 2), 4.59]
    ], result
  end

  def test_single_value
    assert_equal 4.63, @conn.value_on_date("RYA ID Equity", "PX_LAST", "20080101")
  end
end
