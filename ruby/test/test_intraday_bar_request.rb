require "test/unit_test_helper"

class TestIntradayBarRequest < Test::Unit::TestCase
  def setup
    case RubyBloomberg::BLOOMBERG_API
    when 'java'
      @request_field = 'TRADE'
    when 'ole'
      @request_field = 'LAST_PRICE'
    else
      raise RubyBloomberg::BLOOMBERG_API
    end
  end
  
  def test_historical_request
    actual = RubyBloomberg::IntradayBarRequest.submit(
      ["RYA ID Equity"],
      [@request_field],
      {
        :start_date => "2009-07-31 11:00 GMT",
        "end_date" => "2009-07-31 11:30 GMT",
        :barsize => 5,
        :barfields => ["OPEN", "VOLUME"]
      }
    )
    
    expected = ["RYA ID Equity", [3.155, 3.155, 3.156, 3.16], [200, 30000, 1192, 29760]]
    assert_equal expected, actual["RYA ID Equity"]
  end
  
  def test_historical_request
    actual = RubyBloomberg::IntradayBarRequest.submit(
      ["IBM US Equity"],
      [@request_field],
      {
        :start_date => "2009-07-30 12:00 CDT",
        "end_date" => "2009-07-30 12:30 CDT",
        :barsize => 5,
        :barfields => ["OPEN", "VOLUME"]
      }
    )
    
    expected = ["IBM US Equity", [118.54, 118.85, 118.79, 118.69, 118.7, 118.7], [92902.0, 75122.0, 24858.0, 22228.0, 32122.0, 23013.0]]
    assert_equal expected, actual["IBM US Equity"]
  end
end
