module ForgetMeNot
  class Table
    attr_accessor :headers
    attr_reader :rows
    
    def initialize
      @rows = []
      @headers = []
    end
    
    def set_header_at_index(index, header_name)
      @headers[index] = header_name
    end
    
    def append(row)
      case row
      when Row
        # It's already a ForgetMeNot row, leave it alone.
      when Array
        row = Row.new(row)
      else
        raise row.class.name
      end
      
      @rows << row
      row.table = self
    end
    
    def include?(row)
      @rows.include?(row)
    end
    
    def to_a
      [@headers] + @rows.collect {|r| r.to_a }
    end
    
    def value
      raise "value method only valid if 1 row and 1 column" unless @rows.size == 1 && @rows.first.to_a.size == 2
      @rows.first.to_a[1]
    end
    
    # Return a virtual column of data
    def column(column_name_or_index)
      case column_name_or_index
      when String
        index = @headers.index(column_name_or_index)
      when Integer
        index = column_name_or_index
      else
        raise "#{column_name_or_index} has class #{column_name_or_index.class.name}"
      end
      
      raise "#{column_name_or_index} not found!" if index.nil?
      
      @rows.collect {|r| r.to_a[index]}
    end
    
  end # Table class
  
  class Row
    def initialize(data = [])
      @data = data
    end
    
    def table=(table)
      raise unless table.include?(self)
      @table = table
    end
    
    def append(value)
      @data << value
    end
    
    def append_to_array(index, value)
      @data[index] << value
    end
    
    def []=(index, value)
      @data[index] = value
    end
    
    def to_a
      @data
    end
    
    def valid_headers
      @table.headers.length == @data.length
    end
    
    def to_hash
      raise "headers do not match data" unless valid_headers
      Hash[*@table.headers.zip(@data).to_a.flatten]
    end
  end
end
