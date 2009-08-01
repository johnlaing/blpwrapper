module RubyBloomberg
  class ReferenceDataRequest < OleRequest
    def submit
      raise "params not implemented for ReferenceDataRequest" unless @params.empty?
      
      raw_result = data_service.BLPSubscribe(@securities, @fields, @override_fields, @overrides)
      
      @data_table.set_header_at_index(0, "security")
      
      @fields.each_with_index do |f, i|
        @data_table.set_header_at_index(i + 1, f)
      end
      
      @securities.each_with_index do |s, i|
        @data_table.append([s] + raw_result[i])
      end
    end
  end
end