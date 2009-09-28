module RubyBloomberg
  class HistoricalDataRequest < JavaRequest
    def read_message_data(message)
      prepare_historical_data_table
      
      0.upto(message.numElements - 1) do |i|
        raise "i not expected to be > 0, is #{i}" if i > 0
        
        security_data = message.asElement.getElement(i)
        sequence_number = security_data.getElement("sequenceNumber").value_as_int32
        field_data_array = security_data.getElement("fieldData")

        0.upto(field_data_array.numValues - 1) do |j|
          # j is number of dates
          
          field_data = field_data_array.getValueAsElement(j)
          
          date = field_value(field_data.getElement(0))
          @data_table.rows[0].append_to_array(1, Time.parse(date)) if sequence_number == 0
          
          1.upto(field_data.numElements - 1) do |k|
            # k is number of fields
            field = field_data.getElement(k)
            @data_table.rows[sequence_number+1].append_to_array(k, field_value(field))
          end
        end
      end
    end
  end
end
