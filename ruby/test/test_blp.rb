require "test/unit"
require "blpwrapper"

class TestBlp < Test::Unit::TestCase
  def setup
    @conn = Blpwrapper.new
  end

  def test_passing_strings
    assert_equal "RYANAIR HOLDINGS PLC", @conn.blp("RYA ID Equity", "NAME", :value)
  end

  def test_returning_hashes
    fields = %w{NAME PX_LAST}
    h = @conn.blp("RYA ID Equity", fields, :hash).first
    assert_equal fields, h.keys.sort
    assert_equal "RYANAIR HOLDINGS PLC", h['NAME']
  end

  def test_passing_arrays
    data_result = @conn.blp(["AMZN US Equity", "GOOG US Equity"], ["NAME", "PX_LAST"])
    assert_equal "AMAZON.COM INC", data_result[0][0]
    assert_kind_of String, data_result[0][0]
    assert_kind_of Numeric, data_result[0][1]
  end
end
