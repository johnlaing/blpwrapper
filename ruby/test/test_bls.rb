require "test/unit"
require "blpwrapper"

class TestBls < Test::Unit::TestCase
  def setup
    @conn = Blpwrapper.new
  end

  def test_passing_arrays
    data_result = @conn.bls("C US Equity", "DVD_HIST", :hash)
    h = data_result.first
    assert_kind_of Date, h["Declared Date"]
    assert_kind_of Numeric, h["Dividend Amount"]
  end
end
