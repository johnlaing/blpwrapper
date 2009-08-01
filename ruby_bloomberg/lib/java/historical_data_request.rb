module RubyBloomberg
  class HistoricalDataRequest < JavaRequest
    def read_message_data(message)
      @data_table.set_header_at_index(0, "security")
      
      # Iterate over message elements and append to our data hash
      0.upto(message.numElements - 1) do |i|
        security_data = message.asElement.getElement(i)

        security_code = security_data.getElementAsString("security")
        field_data_array = security_data.getElement("fieldData")

        0.upto(field_data_array.numValues - 1) do |j|
          field_data = field_data_array.getValueAsElement(j)

          row = ForgetMeNot::Row.new
          row.append(security_code)

          0.upto(field_data.numElements - 1) do |k|
            field = field_data.getElement(k)

            if @data_table.headers[k+1].nil?
              @data_table.set_header_at_index(k+1, field.name.to_s)
            else
              raise "field names #{field.name}, #{@data_table.headers[k+1]} do not match!" unless @data_table.headers[k+1] === field.name.to_s
            end

            row.append field_value(field)
          end
          @data_table.append(row)
        end
      end
    end
  end
end
