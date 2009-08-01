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
end