require "test/unit_test_helper"

class Security
  include RubyBloomberg::Security
  
  def bloomberg_ticker
    "RYA ID Equity"
  end
end

class TestSecurity < Test::Unit::TestCase
  def setup
    @security = Security.new
  end
  
  def test_fetch_name_field
    assert_equal "RYANAIR HOLDINGS PLC", @security.bdp("NAME")
  end
  
  def test_fetch_price_field
    assert_kind_of Float, @security.bdp("PX_LAST")
  end
  
  def test_historical
    dates = [
      Date.civil(2009, 2, 2),
      Date.civil(2009, 2, 3),
      Date.civil(2009, 2, 4),
      Date.civil(2009, 2, 5),
      Date.civil(2009, 2, 6),
      Date.civil(2009, 2, 9),
      Date.civil(2009, 2, 10)
    ]
    
    expected = [["security", "PX_LAST"], ["date", dates], ["RYA ID Equity", [3.07, 3.15, 3.275, 3.395, 3.41, 3.384, 3.23]]]
    
    assert_equal(expected, @security.bdh("PX_LAST", {:start_date => "2009-02-01", :end_date => "2009-02-10"}).to_a)
  end
end