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
      Time.parse("2009-02-02"),
      Time.parse("2009-02-03"),
      Time.parse("2009-02-04"),
      Time.parse("2009-02-05"),
      Time.parse("2009-02-06"),
      Time.parse("2009-02-09"),
      Time.parse("2009-02-10")
    ]
    
    expected = [["security", "PX_LAST"], ["date", dates], ["RYA ID Equity", [3.07, 3.15, 3.275, 3.395, 3.41, 3.384, 3.23]]]
    
    assert_equal(expected, @security.bdh("PX_LAST", {:start_date => "2009-02-01", :end_date => "2009-02-10"}).to_a)
  end
end