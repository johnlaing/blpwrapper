require "test/unit_test_helper"

class TestBasicRequest < Test::Unit::TestCase
  def setup
    @d = RubyBloomberg::ReferenceDataRequest.submit(
      ["IBM US Equity", "MSFT US Equity"],
      ["PX_LAST", "NAME"]
    )
  end
  
  def test_return_class
    assert_kind_of ForgetMeNot::Table, @d
  end
  
  def test_return_headers
    assert_equal %w{security PX_LAST NAME}, @d.headers
  end
  
  def test_return_names
    assert_equal ["INTL BUSINESS MACHINES CORP", "MICROSOFT CORP"], @d.column("NAME")
  end
end

class TestRequestWithOverrides < Test::Unit::TestCase
  def setup
    @d = RubyBloomberg::ReferenceDataRequest.submit(
      ["RYA ID Equity", "OCN US Equity"],
      "CUST_TRR_RETURN_HOLDING_PER",
      {},
      ["CUST_TRR_START_DT", "CUST_TRR_END_DT", "CUST_TRR_CRNCY"],
      ["20080103", "20080110", "PRC"]
    )
  end
  
  # [["security", "CUST_TRR_RETURN_HOLDING_PER"], ["RYA ID Equity", -9.8266], ["OCN US Equity", -17.2962]]
  def test_return_data
    assert_in_delta -9.8266, @d.to_a[1][1], 0.0001
    assert_in_delta -17.2962, @d.to_a[2][1], 0.0001
  end
end