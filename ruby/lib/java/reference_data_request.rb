module RubyBloomberg
  class ReferenceDataRequest < JavaRequest
    
    def read_message_data(message)
      prepare_reference_data_table

      raise "oops, thought there was only going to be 1 element here, better rethink this!" unless message.numElements == 1
      security_data_array = message.getElement("securityData")
      
      0.upto(security_data_array.numValues - 1) do |i|
        security_data = security_data_array.getValueAsElement(i)
        security_code = security_data.getElementAsString("security")
        sequence_number = security_data.getElement("sequenceNumber").value_as_int32
        
        if security_data.hasElement("securityError")
          raise security_data.getElement("securityError").to_s
        end
        
        field_data = security_data.getElement("fieldData")

        0.upto(field_data.numElements - 1) do |k|
          field = field_data.getElement(k)
          field_index = @fields.index(field.name.to_s)
          
          @data_table.rows[sequence_number][k+1] = field_value(field)
        end
      end
    end
  end
end
