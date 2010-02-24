require "test/unit_test_helper"

class TestConnection < Test::Unit::TestCase
  def test_data_session_is_not_nil_after_connect
    b = RubyBloomberg::Connection.instance
    b.connect
    assert_not_nil b.data_service
  end
end