require "test/unit_test_helper"

class TestHistoricalDataRequest < Test::Unit::TestCase
  def test_historical_request
    actual = RubyBloomberg::HistoricalDataRequest.submit(
      ["IBM US Equity", "MSFT US Equity"],
      ["PX_LAST", "VOLUME"],
      {
        :startDate => "2006-01-01",
        "endDate" => Time.parse("2006-01-10")
      }
    )
    
    expected = ["IBM US Equity", [82.06, 81.95, 82.5, 84.95, 83.73, 84.07], [11715200.0, 9840600.0, 7213500.0, 8197400.0, 6858200.0, 5701000.0]]
    assert_equal expected, actual["IBM US Equity"].to_a
  end
end
