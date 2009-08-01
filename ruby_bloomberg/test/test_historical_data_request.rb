require "test/unit_test_helper"

class TestHistoricalDataRequest < Test::Unit::TestCase
  def setup
    @d = RubyBloomberg::HistoricalDataRequest.submit(
      ["IBM US Equity", "MSFT US Equity"],
      ["PX_LAST", "VOLUME"],
      {
        # "periodicityAdjustment" => "ACTUAL",
        # "periodicitySelection" => "MONTHLY",
        :startDate => "2006-01-01",
        "endDate" => Date.strptime("2006-12-31"),
        # "maxDataPoints" => 100,
        # "returnEids" => true
      }
      )
      
      puts @d.inspect
  end
  
  def test_xyz
#    assert_equal ["INTL BUSINESS MACHINES CORP", "MICROSOFT CORP"], @d.column("NAME")
  end
end
