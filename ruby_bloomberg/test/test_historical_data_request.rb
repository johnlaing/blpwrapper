require "test/unit_test_helper"

class TestHistoricalDataRequest < Test::Unit::TestCase
  def setup
    @d = RubyBloomberg::HistoricalDataRequest.submit(
      ["IBM US Equity", "MSFT US Equity"],
      ["PX_LAST", "VOLUME"],
      {
        :startDate => "2006-01-01",
        "endDate" => Date.strptime("2006-01-10")
      }
    )
  end
  
  def test_historical_request
    dates = ["2006-01-03", "2006-01-04", "2006-01-05", "2006-01-06", "2006-01-09", "2006-01-10"]
    dates = dates.collect {|d| Date.strptime(d)}
    
    expected = [
      ["security", "PX_LAST", "VOLUME"], 
      ["date", dates, dates],
      ["IBM US Equity", [82.06, 81.95, 82.5, 84.95, 83.73, 84.07], [11715200.0, 9840600.0, 7213500.0, 8197400.0, 6858200.0, 5701000.0]],
      ["MSFT US Equity", [26.84, 26.97, 26.99, 26.91, 26.86, 27.0], [79974418.0, 57975661.0, 48247610.0, 100969092.0, 55627836.0, 64924946.0]]
    ]
    
    assert_equal expected, @d.to_a
  end
end
