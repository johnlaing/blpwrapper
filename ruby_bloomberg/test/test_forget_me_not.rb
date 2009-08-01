require "test/unit_test_helper"

class TestForgetMeNot < Test::Unit::TestCase
  def setup
    @row = ForgetMeNot::Row.new
    @table = ForgetMeNot::Table.new
  end
  
  def test_append_data
    @row.append(5)
    assert_equal [5], @row.to_a
  end
  
  def test_append_array
    @row.append(1)
    @row.append([2,3,4])
    
    assert_equal [1, [2,3,4]], @row.to_a
  end
  
  def test_place_data_at_an_index
    @row[2] = 100
    assert_equal [nil, nil, 100], @row.to_a
  end
  
  def test_to_hash
    @row.append(1)
    @row.append(2)
    @row.append(3)
    
    @table.headers = %w{a b c}
    
    @table.append(@row)
    
    assert_equal({'a' => 1, 'b' => 2, 'c' => 3}, @row.to_hash)
  end
  
  def test_to_array
    @table.headers = %w{a b c}
    
    @table.append([1,2,3])
    @table.append([4,5,6])
    
    assert_equal [['a', 'b', 'c'], [1, 2, 3], [4, 5, 6]], @table.to_a
  end
end
